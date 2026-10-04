import com.sun.jdi.*;
import com.sun.jdi.connect.Connector;
import com.sun.jdi.connect.LaunchingConnector;
import com.sun.jdi.event.*;
import com.sun.jdi.request.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Tracer for Java solutions: launches the compiled test driver (Main) on one test case in a second JVM and steps
 * through Solution.java line by line over JDI. Produces the same report as tracer.py (trace and eval modes); see
 * languages/__init__.py for the trace protocol. Watch, console and condition expressions use a small Java subset
 * (see Expr): literals, variables, fields, array indexing, method calls and the usual operators.
 *
 * usage: java JdiTracer <entry point>   (run in the directory holding the compiled classes)
 */
public class JdiTracer {
    static final String SOURCE = "Solution.java";
    static final int MAX_STEPS = 2000, MAX_REPR = 200, MAX_VARS = 50, MAX_FRAMES = 20, MAX_ELEMENTS = 50;
    static final int MAX_STDOUT = 20_000, MAX_REPORT_CHARS = 3_000_000;
    static final String[] EXCLUDED = {"java.*", "javax.*", "jdk.*", "sun.*", "com.sun.*", "Main", "Json"};
    static final String TARGET_OPTIONS = "-cp . -Xmx256m -Xss64m -XX:+UseSerialGC -XX:TieredStopAtLevel=1 -XX:-UsePerfData";

    final String nonce, entry;
    final Map<?, ?> evalSpec;
    final Map<Integer, String> conditions = new HashMap<>();
    final List<String> steps = new ArrayList<>();
    final StringBuilder stdout = new StringBuilder();
    int budget = MAX_REPORT_CHARS;
    VirtualMachine vm;
    final List<EventRequest> active = new ArrayList<>();
    boolean quiet;

    JdiTracer(String nonce, String entry, Map<?, ?> spec) {
        this.nonce = nonce;
        this.entry = entry;
        this.evalSpec = (Map<?, ?>) spec.get("eval");
        Object conds = spec.get("conditions");
        if (conds != null) {
            for (Object c : Json.list(conds)) {
                Map<?, ?> m = (Map<?, ?>) c;
                conditions.put(((Number) m.get("line")).intValue(), (String) m.get("expr"));
            }
        }
    }

    public static void main(String[] argv) throws Exception {
        String input = new String(System.in.readAllBytes(), StandardCharsets.UTF_8);
        int split = input.indexOf('\n');
        Map<?, ?> spec = (Map<?, ?>) Json.parse(input.substring(split + 1));
        JdiTracer tracer = new JdiTracer(input.substring(0, split), argv[0], spec);
        try {
            tracer.run(Json.list(spec.get("args")));
        } catch (Exception e) {
            tracer.finish("{\"steps\":" + tracer.stepsJson() + ",\"error\":" + Json.quote("tracer failed: " + e) + "}");
        }
    }

    // ---- driving the target VM ----

    void run(List<Object> args) throws Exception {
        LaunchingConnector connector = Bootstrap.virtualMachineManager().defaultConnector();
        Map<String, Connector.Argument> launch = connector.defaultArguments();
        launch.get("main").setValue("Main");
        launch.get("options").setValue(TARGET_OPTIONS);
        vm = connector.launch(launch);
        Process process = vm.process();
        pump(process.getInputStream(), true);
        pump(process.getErrorStream(), false);
        try (OutputStream in = process.getOutputStream()) {
            in.write(("driver\n[" + Json.write(args) + "]").getBytes(StandardCharsets.UTF_8));
        }

        EventRequestManager requests = vm.eventRequestManager();
        MethodEntryRequest entryRequest = requests.createMethodEntryRequest();
        exclude(entryRequest);
        entryRequest.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
        entryRequest.enable();

        boolean started = false;
        String outcome = null;
        EventQueue queue = vm.eventQueue();
        while (true) {
            EventSet set = queue.remove();
            for (Event event : set) {
                if (event instanceof VMDeathEvent || event instanceof VMDisconnectEvent) {
                    if (evalSpec != null) finish("{\"error\":\"the program finished before reaching this step\"}");
                    String error = started ? "the program exited before the solution returned" : "the solution was never called";
                    finish("{\"steps\":" + stepsJson() + ",\"truncated\":false,\"error\":" + Json.quote(error) + "}");
                }
                if (event instanceof MethodEntryEvent) {
                    MethodEntryEvent e = (MethodEntryEvent) event;
                    if (started || !e.method().name().equals(entry) || !inSource(e.location())) continue;
                    started = true;
                    entryRequest.disable();
                    ThreadReference thread = e.thread();
                    StepRequest step = requests.createStepRequest(thread, StepRequest.STEP_LINE, StepRequest.STEP_INTO);
                    MethodExitRequest exit = requests.createMethodExitRequest();
                    ExceptionRequest exception = requests.createExceptionRequest(null, true, true);
                    for (EventRequest r : List.of(step, exit)) exclude(r);
                    for (EventRequest r : List.of(step, exit, exception)) {
                        r.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
                        r.enable();
                        active.add(r);
                    }
                    record(thread, "line", null);
                } else if (event instanceof StepEvent) {
                    StepEvent e = (StepEvent) event;
                    if (inSource(e.location())) record(e.thread(), "line", null);
                } else if (event instanceof MethodExitEvent) {
                    MethodExitEvent e = (MethodExitEvent) event;
                    if (!inSource(e.location())) continue;
                    ThreadReference thread = e.thread();
                    boolean last = e.method().name().equals(entry) && solutionFrames(thread).size() == 1;
                    String value = e.method().returnTypeName().equals("void") ? null : show(thread, e.returnValue());
                    record(thread, "return", value == null ? null : ",\"value\":" + Json.quote(value));
                    if (last) outcome = ",\"result\":" + Json.quote(value == null ? "null" : value);
                } else if (event instanceof ExceptionEvent) {
                    ExceptionEvent e = (ExceptionEvent) event;
                    Location caught = e.catchLocation();
                    // Ignore exceptions the JDK throws and handles internally.
                    if (caught != null && !inSource(caught) && !caught.declaringType().name().equals("Main")) continue;
                    ThreadReference thread = e.thread();
                    if (solutionFrames(thread).isEmpty()) continue;
                    String message = describe(e.exception());
                    record(thread, "exception", ",\"exception\":" + Json.quote(message));
                    if (caught == null || !inSource(caught)) outcome = ",\"error\":" + Json.quote(message);
                }
            }
            if (outcome != null) {
                if (evalSpec != null) finish("{\"error\":\"the program finished before reaching this step\"}");
                finish("{\"steps\":" + stepsJson() + ",\"truncated\":false" + outcome + "}");
            }
            set.resume();
        }
    }

    static void exclude(EventRequest r) {
        for (String pattern : EXCLUDED) {
            if (r instanceof StepRequest) ((StepRequest) r).addClassExclusionFilter(pattern);
            else if (r instanceof MethodEntryRequest) ((MethodEntryRequest) r).addClassExclusionFilter(pattern);
            else if (r instanceof MethodExitRequest) ((MethodExitRequest) r).addClassExclusionFilter(pattern);
        }
    }

    void pump(InputStream stream, boolean keep) {
        Thread t = new Thread(() -> {
            byte[] buf = new byte[8192];
            try {
                for (int n; (n = stream.read(buf)) > 0; ) {
                    if (!keep) continue;
                    synchronized (stdout) {
                        if (stdout.length() < MAX_STDOUT) stdout.append(new String(buf, 0, n, StandardCharsets.UTF_8));
                    }
                }
            } catch (IOException ignored) {
                // The target exited.
            }
        });
        t.setDaemon(true);
        t.start();
    }

    int stdoutLength() {
        // Give the pump a moment to drain what the target printed before it stopped at this step.
        try {
            Thread.sleep(0, 200_000);
        } catch (InterruptedException ignored) {
        }
        synchronized (stdout) {
            return Math.min(stdout.length(), MAX_STDOUT);
        }
    }

    void finish(String payload) {
        String out;
        synchronized (stdout) {
            out = stdout.substring(0, Math.min(stdout.length(), MAX_STDOUT));
        }
        String report = payload.substring(0, payload.length() - 1) + ",\"stdout\":" + Json.quote(out) + "}";
        System.out.print("\n" + nonce + report + nonce + "\n");
        System.out.flush();
        // The target dies with the sandbox's process group; exit without waiting for it.
        Runtime.getRuntime().halt(0);
    }

    String stepsJson() {
        return "[" + String.join(",", steps) + "]";
    }

    // ---- recording ----

    static boolean inSource(Location location) {
        try {
            return SOURCE.equals(location.sourceName());
        } catch (AbsentInformationException e) {
            return false;
        }
    }

    static List<StackFrame> solutionFrames(ThreadReference thread) throws IncompatibleThreadStateException {
        List<StackFrame> frames = new ArrayList<>();
        for (StackFrame f : thread.frames()) if (inSource(f.location())) frames.add(f);
        return frames;
    }

    /** What a frame shows, read up front: invoking methods (toString, watches) resumes the thread and invalidates it. */
    static final class Snapshot {
        final String name;
        final int line;
        final Map<String, Value> vars = new LinkedHashMap<>();
        final ObjectReference self;

        Snapshot(StackFrame frame) {
            Method method = frame.location().method();
            name = method.name().equals("<init>") ? method.declaringType().name() : method.name();
            line = frame.location().lineNumber();
            self = frame.thisObject();
            try {
                List<LocalVariable> visible = frame.visibleVariables();
                for (Map.Entry<LocalVariable, Value> e : frame.getValues(visible).entrySet()) vars.put(e.getKey().name(), e.getValue());
            } catch (AbsentInformationException ignored) {
                // Compiled without -g: no locals to show.
            }
        }
    }

    void record(ThreadReference thread, String event, String extra) throws Exception {
        List<StackFrame> frames = solutionFrames(thread);
        List<Snapshot> snaps = new ArrayList<>();
        for (StackFrame f : frames.subList(0, Math.min(frames.size(), MAX_FRAMES))) snaps.add(new Snapshot(f));
        int index = steps.size();

        try {
            if (evalSpec != null && index == ((Number) evalSpec.get("step")).intValue()) {
                int frame = ((Number) evalSpec.get("frame")).intValue();
                if (frame >= snaps.size()) finish("{\"error\":\"frame no longer exists at this step\"}");
                List<String> values = new ArrayList<>();
                for (Object expr : Json.list(evalSpec.get("expressions"))) values.add(evaluate(thread, snaps.get(frame), (String) expr));
                finish("{\"values\":[" + String.join(",", values) + "]}");
            }

            Snapshot top = snaps.get(0);
            StringBuilder step = new StringBuilder("{\"line\":").append(top.line)
                .append(",\"event\":\"").append(event).append('"')
                .append(",\"depth\":").append(frames.size())
                .append(",\"out\":").append(stdoutLength());
            if (extra != null) step.append(extra);
            if (event.equals("line") && conditions.containsKey(top.line)) {
                try {
                    Object v = new Expr(conditions.get(top.line), this, thread, top).parse();
                    step.append(",\"cond\":").append(Expr.truthy(v));
                } catch (Exception e) {
                    // A condition that fails still pauses, as in most debuggers, so the mistake is visible.
                    step.append(",\"cond\":true,\"condError\":").append(Json.quote(message(e)));
                }
            }
            if (evalSpec == null) {
                step.append(",\"frames\":[");
                for (int k = 0; k < snaps.size(); k++) {
                    Snapshot s = snaps.get(k);
                    step.append(k > 0 ? "," : "").append("{\"name\":").append(Json.quote(s.name))
                        .append(",\"line\":").append(s.line).append(",\"locals\":{");
                    int n = 0;
                    for (Map.Entry<String, Value> e : s.vars.entrySet()) {
                        if (n++ >= MAX_VARS) break;
                        step.append(n > 1 ? "," : "").append(Json.quote(e.getKey())).append(':').append(Json.quote(show(thread, e.getValue())));
                    }
                    if (s.self != null && n < MAX_VARS) {
                        step.append(n > 0 ? "," : "").append("\"this\":").append(Json.quote(show(thread, s.self)));
                    }
                    step.append("}}");
                }
                step.append(']');
            }
            step.append('}');
            if (evalSpec == null) {
                budget -= step.length();
                if (budget < 0) finish("{\"steps\":" + stepsJson() + ",\"truncated\":true}");
            }
            steps.add(step.toString());
            if (steps.size() >= MAX_STEPS && evalSpec == null) finish("{\"steps\":" + stepsJson() + ",\"truncated\":true}");
        } finally {
            if (quiet) {
                for (EventRequest r : active) r.enable();
                quiet = false;
            }
        }
    }

    /** Before invoking a method in the target: keep our step/exit/exception requests from firing inside it. */
    void hush() {
        if (quiet) return;
        for (EventRequest r : active) r.disable();
        quiet = true;
    }

    String evaluate(ThreadReference thread, Snapshot frame, String expr) {
        try {
            return "{\"value\":" + Json.quote(show(thread, new Expr(expr, this, thread, frame).parse())) + "}";
        } catch (Exception e) {
            return "{\"error\":" + Json.quote(message(e)) + "}";
        }
    }

    static String message(Exception e) {
        return e.getMessage() != null ? e.getMessage() : e.toString();
    }

    // ---- formatting values ----

    static String clip(String s) {
        return s.length() <= MAX_REPR ? s : s.substring(0, MAX_REPR) + "...";
    }

    /** A JDI value (or a plain Java value from Expr) as text, Java style. */
    String show(ThreadReference thread, Object v) {
        return clip(format(thread, v, 0));
    }

    String format(ThreadReference thread, Object v, int depth) {
        if (v == null) return "null";
        if (v instanceof String) return Json.quote((String) v);
        if (v instanceof Character || v instanceof CharValue) return "'" + (v instanceof CharValue ? ((CharValue) v).value() : v) + "'";
        if (!(v instanceof Value)) return String.valueOf(v);
        if (v instanceof StringReference) return Json.quote(((StringReference) v).value());
        if (v instanceof PrimitiveValue) return v.toString();
        if (v instanceof ArrayReference) {
            ArrayReference a = (ArrayReference) v;
            if (depth > 2) return "[...]";
            StringBuilder b = new StringBuilder("[");
            int n = Math.min(a.length(), MAX_ELEMENTS);
            List<Value> items = n == 0 ? List.of() : a.getValues(0, n);
            for (int k = 0; k < n && b.length() <= MAX_REPR; k++) b.append(k > 0 ? ", " : "").append(format(thread, items.get(k), depth + 1));
            if (a.length() > n || b.length() > MAX_REPR) b.append(", ...");
            return b.append(']').toString();
        }
        ObjectReference o = (ObjectReference) v;
        Value boxed = unbox(o);
        if (boxed != null) return format(thread, boxed, depth);
        try {
            Method toString = ((ClassType) o.referenceType()).concreteMethodByName("toString", "()Ljava/lang/String;");
            if (toString.declaringType().name().equals("java.lang.Object")) {
                // No toString of its own (e.g. Solution, a ListNode): show the fields, like a debugger does.
                if (depth > 2) return o.referenceType().name() + "{...}";
                StringBuilder b = new StringBuilder(o.referenceType().name()).append('{');
                int n = 0;
                for (Field f : o.referenceType().allFields()) {
                    if (f.isStatic() || f.isSynthetic()) continue;
                    if (b.length() > MAX_REPR) return b.append(", ...}").toString();
                    b.append(n++ > 0 ? ", " : "").append(f.name()).append('=').append(format(thread, o.getValue(f), depth + 1));
                }
                return b.append('}').toString();
            }
            hush();
            Value text = o.invokeMethod(thread, toString, List.of(), ObjectReference.INVOKE_SINGLE_THREADED);
            return text instanceof StringReference ? ((StringReference) text).value() : o.referenceType().name();
        } catch (Exception e) {
            return o.referenceType().name();
        }
    }

    static Value unbox(ObjectReference o) {
        String type = o.referenceType().name();
        if (!type.startsWith("java.lang.")) return null;
        switch (type.substring(10)) {
            case "Integer": case "Long": case "Short": case "Byte": case "Double": case "Float": case "Character": case "Boolean":
                return o.getValue(o.referenceType().fieldByName("value"));
            default:
                return null;
        }
    }

    String describe(ObjectReference exception) {
        Field detail = exception.referenceType().fieldByName("detailMessage");
        Value message = detail == null ? null : exception.getValue(detail);
        String name = exception.referenceType().name();
        return message instanceof StringReference ? name + ": " + ((StringReference) message).value() : name;
    }

    static final Set<String> PRIMITIVES = Set.of("int", "long", "double", "float", "boolean", "char", "short", "byte");

    /** Invokes the instance method `name` whose parameters accept `args` (JDI values), boxing primitives for Object parameters. */
    Value invoke(ThreadReference thread, ObjectReference target, String name, List<Value> args) throws Exception {
        for (Method m : target.referenceType().methodsByName(name)) {
            List<String> params = m.argumentTypeNames();
            if (m.isStatic() || params.size() != args.size()) continue;
            List<Value> actual = new ArrayList<>();
            for (int k = 0; k < args.size(); k++) {
                Value a = args.get(k);
                actual.add(a instanceof PrimitiveValue && !PRIMITIVES.contains(params.get(k)) ? box(thread, (PrimitiveValue) a) : a);
            }
            try {
                hush();
                return target.invokeMethod(thread, m, actual, ObjectReference.INVOKE_SINGLE_THREADED);
            } catch (InvalidTypeException | ClassNotLoadedException e) {
                // Try the next overload.
            }
        }
        throw new IllegalArgumentException("no method " + name + " taking " + args.size() + " argument(s)");
    }

    /** Boxes a primitive so it can be passed where an Object is expected (e.g. map.get(key)). */
    Value box(ThreadReference thread, PrimitiveValue p) throws Exception {
        String type = p instanceof IntegerValue ? "Integer" : p instanceof LongValue ? "Long" : p instanceof DoubleValue ? "Double"
            : p instanceof BooleanValue ? "Boolean" : p instanceof CharValue ? "Character" : null;
        if (type == null) return p;
        ClassType cls = (ClassType) vm.classesByName("java.lang." + type).get(0);
        for (Method m : cls.methodsByName("valueOf")) {
            if (m.argumentTypeNames().size() == 1 && m.argumentTypeNames().get(0).equals(p.type().name())) {
                hush();
                return cls.invokeMethod(thread, m, List.of(p), ObjectReference.INVOKE_SINGLE_THREADED);
            }
        }
        return p;
    }

    // ---- expressions ----

    /**
     * Recursive-descent evaluator for watch/console/condition expressions. Values are JDI mirrors, or Long/Double/
     * Boolean/String for arithmetic results and literals.
     */
    static final class Expr {
        final String src;
        final JdiTracer tracer;
        final ThreadReference thread;
        final Snapshot frame;
        int i;

        Expr(String src, JdiTracer tracer, ThreadReference thread, Snapshot frame) {
            this.src = src;
            this.tracer = tracer;
            this.thread = thread;
            this.frame = frame;
        }

        Object parse() throws Exception {
            Object v = ternary();
            ws();
            if (i < src.length()) throw new IllegalArgumentException("unexpected '" + src.substring(i) + "'");
            return v;
        }

        void ws() {
            while (i < src.length() && Character.isWhitespace(src.charAt(i))) i++;
        }

        boolean eat(String op) {
            ws();
            if (!src.startsWith(op, i)) return false;
            // Don't read "<" out of "<=", or "!" out of "!=".
            if (op.length() == 1 && "<>!".indexOf(op.charAt(0)) >= 0 && i + 1 < src.length() && src.charAt(i + 1) == '=') return false;
            i += op.length();
            return true;
        }

        Object ternary() throws Exception {
            Object c = or();
            if (!eat("?")) return c;
            Object a = ternary();
            if (!eat(":")) throw new IllegalArgumentException("expected ':'");
            Object b = ternary();
            return truthy(c) ? a : b;
        }

        Object or() throws Exception {
            Object v = and();
            while (eat("||")) {
                Object r = and();
                v = truthy(v) || truthy(r);
            }
            return v;
        }

        Object and() throws Exception {
            Object v = equality();
            while (eat("&&")) {
                Object r = equality();
                v = truthy(v) && truthy(r);
            }
            return v;
        }

        Object equality() throws Exception {
            Object v = relational();
            while (true) {
                if (eat("==")) v = same(v, relational());
                else if (eat("!=")) v = !same(v, relational());
                else return v;
            }
        }

        Object relational() throws Exception {
            Object v = additive();
            while (true) {
                if (eat("<=")) v = num(v) <= num(additive());
                else if (eat(">=")) v = num(v) >= num(additive());
                else if (eat("<")) v = num(v) < num(additive());
                else if (eat(">")) v = num(v) > num(additive());
                else return v;
            }
        }

        Object additive() throws Exception {
            Object v = term();
            while (true) {
                if (eat("+")) {
                    Object r = term();
                    v = isText(v) || isText(r) ? text(v) + text(r) : arith(v, r, '+');
                } else if (eat("-")) v = arith(v, term(), '-');
                else return v;
            }
        }

        Object term() throws Exception {
            Object v = unary();
            while (true) {
                if (eat("*")) v = arith(v, unary(), '*');
                else if (eat("/")) v = arith(v, unary(), '/');
                else if (eat("%")) v = arith(v, unary(), '%');
                else return v;
            }
        }

        Object unary() throws Exception {
            if (eat("!")) return !truthy(unary());
            if (eat("-")) return arith(0L, unary(), '-');
            return postfix(primary());
        }

        Object primary() throws Exception {
            ws();
            if (i >= src.length()) throw new IllegalArgumentException("unexpected end of expression");
            char c = src.charAt(i);
            if (eat("(")) {
                Object v = ternary();
                if (!eat(")")) throw new IllegalArgumentException("expected ')'");
                return v;
            }
            if (Character.isDigit(c)) {
                int start = i;
                while (i < src.length() && (Character.isDigit(src.charAt(i)) || src.charAt(i) == '.')) i++;
                String n = src.substring(start, i);
                if (i < src.length() && "lL".indexOf(src.charAt(i)) >= 0) i++;
                return n.contains(".") ? (Object) Double.parseDouble(n) : (Object) Long.parseLong(n);
            }
            if (c == '"') {
                int end = src.indexOf('"', i + 1);
                if (end < 0) throw new IllegalArgumentException("unterminated string");
                String s = src.substring(i + 1, end);
                i = end + 1;
                return s;
            }
            if (c == '\'' && i + 2 < src.length() && src.charAt(i + 2) == '\'') {
                char ch = src.charAt(i + 1);
                i += 3;
                return (long) ch;
            }
            String name = identifier();
            switch (name) {
                case "true": return true;
                case "false": return false;
                case "null": return null;
                case "this":
                    if (frame.self == null) throw new IllegalArgumentException("no 'this' in a static method");
                    return frame.self;
                default:
            }
            if (frame.vars.containsKey(name)) return frame.vars.get(name);
            if (frame.self != null) {
                Field f = frame.self.referenceType().fieldByName(name);
                if (f != null) return frame.self.getValue(f);
            }
            throw new IllegalArgumentException("cannot find symbol: " + name);
        }

        String identifier() {
            ws();
            int start = i;
            while (i < src.length() && (Character.isJavaIdentifierPart(src.charAt(i)))) i++;
            if (start == i) throw new IllegalArgumentException("unexpected '" + src.substring(i) + "'");
            return src.substring(start, i);
        }

        Object postfix(Object v) throws Exception {
            while (true) {
                if (eat("[")) {
                    Object index = ternary();
                    if (!eat("]")) throw new IllegalArgumentException("expected ']'");
                    if (!(v instanceof ArrayReference)) throw new IllegalArgumentException("array required");
                    ArrayReference a = (ArrayReference) v;
                    int k = (int) num(index);
                    if (k < 0 || k >= a.length()) throw new IllegalArgumentException("ArrayIndexOutOfBoundsException: Index " + k + " out of bounds for length " + a.length());
                    v = a.getValue(k);
                } else if (eat(".")) {
                    String name = identifier();
                    if (eat("(")) {
                        List<Value> args = new ArrayList<>();
                        if (!eat(")")) {
                            do args.add(mirror(ternary())); while (eat(","));
                            if (!eat(")")) throw new IllegalArgumentException("expected ')'");
                        }
                        if (v instanceof String) v = tracer.vm.mirrorOf((String) v);
                        if (!(v instanceof ObjectReference)) throw new IllegalArgumentException("cannot call " + name + " on " + tracer.show(thread, v));
                        v = tracer.invoke(thread, (ObjectReference) v, name, args);
                    } else if (v instanceof ArrayReference && name.equals("length")) {
                        v = (long) ((ArrayReference) v).length();
                    } else if (v instanceof ObjectReference) {
                        Field f = ((ObjectReference) v).referenceType().fieldByName(name);
                        if (f == null) throw new IllegalArgumentException("cannot find symbol: " + name);
                        v = ((ObjectReference) v).getValue(f);
                    } else {
                        throw new IllegalArgumentException("cannot read ." + name + " of " + tracer.show(thread, v));
                    }
                } else {
                    return v;
                }
            }
        }

        /** A plain value as a JDI mirror for passing to a method; numbers become int when they fit, then boxed if needed. */
        Value mirror(Object v) throws Exception {
            v = plain(v);
            if (v == null) return null;
            if (v instanceof Value) return (Value) v;
            if (v instanceof String) return tracer.vm.mirrorOf((String) v);
            if (v instanceof Boolean) return tracer.vm.mirrorOf((Boolean) v);
            if (v instanceof Double) return tracer.vm.mirrorOf((Double) v);
            long n = (Long) v;
            return n == (int) n ? tracer.vm.mirrorOf((int) n) : tracer.vm.mirrorOf(n);
        }

        /** JDI primitives and boxes become Long/Double/Boolean; strings become String; other objects stay mirrors. */
        static Object plain(Object v) {
            if (v instanceof ObjectReference && !(v instanceof StringReference) && !(v instanceof ArrayReference)) {
                Value boxed = unbox((ObjectReference) v);
                if (boxed != null) v = boxed;
            }
            if (v instanceof StringReference) return ((StringReference) v).value();
            if (v instanceof BooleanValue) return ((BooleanValue) v).value();
            if (v instanceof CharValue) return (long) ((CharValue) v).value();
            if (v instanceof DoubleValue || v instanceof FloatValue) return ((PrimitiveValue) v).doubleValue();
            if (v instanceof PrimitiveValue) return ((PrimitiveValue) v).longValue();
            return v;
        }

        static boolean truthy(Object v) {
            v = plain(v);
            if (v instanceof Boolean) return (Boolean) v;
            if (v instanceof Long) return (Long) v != 0;
            if (v instanceof Double) return (Double) v != 0;
            return v != null;
        }

        static double num(Object v) {
            v = plain(v);
            if (v instanceof Long) return (Long) v;
            if (v instanceof Double) return (Double) v;
            throw new IllegalArgumentException("number required");
        }

        static boolean isText(Object v) {
            return plain(v) instanceof String;
        }

        String text(Object v) {
            Object p = plain(v);
            return p instanceof String ? (String) p : tracer.format(thread, v, 0);
        }

        static Object arith(Object a, Object b, char op) {
            Object x = plain(a), y = plain(b);
            if (x instanceof Long && y instanceof Long) {
                long l = (Long) x, r = (Long) y;
                if ((op == '/' || op == '%') && r == 0) throw new ArithmeticException("ArithmeticException: / by zero");
                return op == '+' ? l + r : op == '-' ? l - r : op == '*' ? l * r : op == '/' ? l / r : l % r;
            }
            double l = num(x), r = num(y);
            return op == '+' ? l + r : op == '-' ? l - r : op == '*' ? l * r : op == '/' ? l / r : l % r;
        }

        static boolean same(Object a, Object b) {
            Object x = plain(a), y = plain(b);
            if (x instanceof Number && y instanceof Number) return ((Number) x).doubleValue() == ((Number) y).doubleValue();
            return Objects.equals(x, y);
        }
    }
}

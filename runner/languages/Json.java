import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Minimal JSON reader/writer for the Java test driver (the JDK has none built in). */
final class Json {
    private final String s;
    private int i;

    private Json(String s) {
        this.s = s;
    }

    static Object parse(String text) {
        return new Json(text).value();
    }

    private void ws() {
        while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++;
    }

    private Object value() {
        ws();
        char c = s.charAt(i);
        if (c == '{') {
            i++;
            Map<String, Object> m = new LinkedHashMap<>();
            ws();
            if (s.charAt(i) == '}') { i++; return m; }
            while (true) {
                ws();
                String key = string();
                ws();
                i++; // ':'
                m.put(key, value());
                ws();
                if (s.charAt(i++) == '}') return m;
            }
        }
        if (c == '[') {
            i++;
            List<Object> l = new ArrayList<>();
            ws();
            if (s.charAt(i) == ']') { i++; return l; }
            while (true) {
                l.add(value());
                ws();
                if (s.charAt(i++) == ']') return l;
            }
        }
        if (c == '"') return string();
        if (s.startsWith("true", i)) { i += 4; return Boolean.TRUE; }
        if (s.startsWith("false", i)) { i += 5; return Boolean.FALSE; }
        if (s.startsWith("null", i)) { i += 4; return null; }
        int start = i;
        while (i < s.length() && "+-0123456789.eE".indexOf(s.charAt(i)) >= 0) i++;
        String num = s.substring(start, i);
        if (num.contains(".") || num.contains("e") || num.contains("E")) return Double.parseDouble(num);
        return Long.parseLong(num);
    }

    private String string() {
        i++; // opening quote
        StringBuilder b = new StringBuilder();
        while (true) {
            char c = s.charAt(i++);
            if (c == '"') return b.toString();
            if (c != '\\') { b.append(c); continue; }
            char e = s.charAt(i++);
            switch (e) {
                case 'n': b.append('\n'); break;
                case 't': b.append('\t'); break;
                case 'r': b.append('\r'); break;
                case 'b': b.append('\b'); break;
                case 'f': b.append('\f'); break;
                case 'u': b.append((char) Integer.parseInt(s.substring(i, i + 4), 16)); i += 4; break;
                default: b.append(e);
            }
        }
    }

    @SuppressWarnings("unchecked")
    static List<Object> list(Object o) {
        return (List<Object>) o;
    }

    static int toInt(Object o) { return ((Number) o).intValue(); }
    static double toDouble(Object o) { return ((Number) o).doubleValue(); }
    static boolean toBool(Object o) { return (Boolean) o; }
    static String toStr(Object o) { return (String) o; }

    static int[] toIntArray(Object o) {
        List<Object> l = list(o);
        int[] a = new int[l.size()];
        for (int k = 0; k < a.length; k++) a[k] = toInt(l.get(k));
        return a;
    }

    static double[] toDoubleArray(Object o) {
        List<Object> l = list(o);
        double[] a = new double[l.size()];
        for (int k = 0; k < a.length; k++) a[k] = toDouble(l.get(k));
        return a;
    }

    static boolean[] toBoolArray(Object o) {
        List<Object> l = list(o);
        boolean[] a = new boolean[l.size()];
        for (int k = 0; k < a.length; k++) a[k] = toBool(l.get(k));
        return a;
    }

    static String[] toStrArray(Object o) {
        List<Object> l = list(o);
        String[] a = new String[l.size()];
        for (int k = 0; k < a.length; k++) a[k] = toStr(l.get(k));
        return a;
    }

    static int[][] toIntMatrix(Object o) {
        List<Object> l = list(o);
        int[][] a = new int[l.size()][];
        for (int k = 0; k < a.length; k++) a[k] = toIntArray(l.get(k));
        return a;
    }

    static String write(Object o) {
        if (o == null) return "null";
        if (o instanceof String || o instanceof Character) return quote(o.toString());
        if (o instanceof Boolean) return o.toString();
        if (o instanceof Double || o instanceof Float) {
            double d = ((Number) o).doubleValue();
            return Double.isFinite(d) ? Double.toString(d) : "null";
        }
        if (o instanceof Number) return o.toString();
        StringBuilder b = new StringBuilder("[");
        if (o instanceof int[]) {
            int[] a = (int[]) o;
            for (int k = 0; k < a.length; k++) b.append(k > 0 ? "," : "").append(a[k]);
        } else if (o instanceof long[]) {
            long[] a = (long[]) o;
            for (int k = 0; k < a.length; k++) b.append(k > 0 ? "," : "").append(a[k]);
        } else if (o instanceof double[]) {
            double[] a = (double[]) o;
            for (int k = 0; k < a.length; k++) b.append(k > 0 ? "," : "").append(write(a[k]));
        } else if (o instanceof boolean[]) {
            boolean[] a = (boolean[]) o;
            for (int k = 0; k < a.length; k++) b.append(k > 0 ? "," : "").append(a[k]);
        } else if (o instanceof char[]) {
            return quote(new String((char[]) o));
        } else if (o instanceof Object[]) {
            Object[] a = (Object[]) o;
            for (int k = 0; k < a.length; k++) b.append(k > 0 ? "," : "").append(write(a[k]));
        } else if (o instanceof Iterable) {
            boolean first = true;
            for (Object x : (Iterable<?>) o) { b.append(first ? "" : ",").append(write(x)); first = false; }
        } else if (o instanceof Map) {
            StringBuilder m = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<?, ?> e : ((Map<?, ?>) o).entrySet()) {
                m.append(first ? "" : ",").append(quote(String.valueOf(e.getKey()))).append(':').append(write(e.getValue()));
                first = false;
            }
            return m.append('}').toString();
        } else {
            return quote(o.toString());
        }
        return b.append(']').toString();
    }

    static String quote(String s) {
        StringBuilder b = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': b.append("\\\""); break;
                case '\\': b.append("\\\\"); break;
                case '\n': b.append("\\n"); break;
                case '\r': b.append("\\r"); break;
                case '\t': b.append("\\t"); break;
                default:
                    if (c < 0x20) b.append(String.format("\\u%04x", (int) c));
                    else b.append(c);
            }
        }
        return b.append('"').toString();
    }
}

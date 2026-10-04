using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

/// Minimal JSON reader/writer for the C# test driver (Mono ships no convenient JSON API).
static class Json
{
    public static object Parse(string text)
    {
        int i = 0;
        return Value(text, ref i);
    }

    static void Ws(string s, ref int i)
    {
        while (i < s.Length && char.IsWhiteSpace(s[i])) i++;
    }

    static object Value(string s, ref int i)
    {
        Ws(s, ref i);
        char c = s[i];
        if (c == '{')
        {
            i++;
            var m = new Dictionary<string, object>();
            Ws(s, ref i);
            if (s[i] == '}') { i++; return m; }
            while (true)
            {
                Ws(s, ref i);
                string key = Str(s, ref i);
                Ws(s, ref i);
                i++; // ':'
                m[key] = Value(s, ref i);
                Ws(s, ref i);
                if (s[i++] == '}') return m;
            }
        }
        if (c == '[')
        {
            i++;
            var l = new List<object>();
            Ws(s, ref i);
            if (s[i] == ']') { i++; return l; }
            while (true)
            {
                l.Add(Value(s, ref i));
                Ws(s, ref i);
                if (s[i++] == ']') return l;
            }
        }
        if (c == '"') return Str(s, ref i);
        if (string.CompareOrdinal(s, i, "true", 0, 4) == 0) { i += 4; return true; }
        if (string.CompareOrdinal(s, i, "false", 0, 5) == 0) { i += 5; return false; }
        if (string.CompareOrdinal(s, i, "null", 0, 4) == 0) { i += 4; return null; }
        int start = i;
        while (i < s.Length && "+-0123456789.eE".IndexOf(s[i]) >= 0) i++;
        string num = s.Substring(start, i - start);
        if (num.IndexOfAny(new[] { '.', 'e', 'E' }) >= 0) return double.Parse(num, CultureInfo.InvariantCulture);
        return long.Parse(num, CultureInfo.InvariantCulture);
    }

    static string Str(string s, ref int i)
    {
        i++; // opening quote
        var b = new StringBuilder();
        while (true)
        {
            char c = s[i++];
            if (c == '"') return b.ToString();
            if (c != '\\') { b.Append(c); continue; }
            char e = s[i++];
            switch (e)
            {
                case 'n': b.Append('\n'); break;
                case 't': b.Append('\t'); break;
                case 'r': b.Append('\r'); break;
                case 'b': b.Append('\b'); break;
                case 'f': b.Append('\f'); break;
                case 'u': b.Append((char)Convert.ToInt32(s.Substring(i, 4), 16)); i += 4; break;
                default: b.Append(e); break;
            }
        }
    }

    public static List<object> List(object o) { return (List<object>)o; }
    public static int ToInt(object o) { return Convert.ToInt32(o, CultureInfo.InvariantCulture); }
    public static double ToDouble(object o) { return Convert.ToDouble(o, CultureInfo.InvariantCulture); }
    public static bool ToBool(object o) { return (bool)o; }
    public static string ToStr(object o) { return (string)o; }
    public static int[] ToIntArray(object o) { return List(o).ConvertAll(ToInt).ToArray(); }
    public static double[] ToDoubleArray(object o) { return List(o).ConvertAll(ToDouble).ToArray(); }
    public static bool[] ToBoolArray(object o) { return List(o).ConvertAll(ToBool).ToArray(); }
    public static string[] ToStrArray(object o) { return List(o).ConvertAll(ToStr).ToArray(); }
    public static int[][] ToIntMatrix(object o) { return List(o).ConvertAll(ToIntArray).ToArray(); }

    public static string Write(object o)
    {
        if (o == null) return "null";
        if (o is string || o is char) return Quote(o.ToString());
        if (o is bool) return (bool)o ? "true" : "false";
        if (o is double || o is float || o is decimal)
        {
            double d = Convert.ToDouble(o, CultureInfo.InvariantCulture);
            return double.IsNaN(d) || double.IsInfinity(d) ? "null" : d.ToString("R", CultureInfo.InvariantCulture);
        }
        if (o is IConvertible) return Convert.ToString(o, CultureInfo.InvariantCulture);
        if (o is IDictionary)
        {
            var m = new StringBuilder("{");
            bool firstEntry = true;
            foreach (DictionaryEntry e in (IDictionary)o)
            {
                m.Append(firstEntry ? "" : ",").Append(Quote(Convert.ToString(e.Key, CultureInfo.InvariantCulture))).Append(':').Append(Write(e.Value));
                firstEntry = false;
            }
            return m.Append('}').ToString();
        }
        if (o is IEnumerable)
        {
            var b = new StringBuilder("[");
            bool first = true;
            foreach (object x in (IEnumerable)o) { b.Append(first ? "" : ",").Append(Write(x)); first = false; }
            return b.Append(']').ToString();
        }
        return Quote(o.ToString());
    }

    public static string Quote(string s)
    {
        var b = new StringBuilder("\"");
        foreach (char c in s)
        {
            switch (c)
            {
                case '"': b.Append("\\\""); break;
                case '\\': b.Append("\\\\"); break;
                case '\n': b.Append("\\n"); break;
                case '\r': b.Append("\\r"); break;
                case '\t': b.Append("\\t"); break;
                default:
                    if (c < 0x20) b.Append("\\u").Append(((int)c).ToString("x4"));
                    else b.Append(c);
                    break;
            }
        }
        return b.Append('"').ToString();
    }
}

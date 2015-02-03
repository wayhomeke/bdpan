r="e17edb7ad969018a979561eb852c5ce5a29298fc";
j="e8c7d729eea7b54551aa594f942decbe";

function s() {
        var a = [];
        var p = [];
        var o = "";
        var v = j.length;
        for (var q = 0; q < 256; q++) {
            a[q] = j.substr((q % v), 1).charCodeAt(0);
            p[q] = q
        }
        for (var u = q = 0; q < 256; q++) {
            u = (u + p[q] + a[q]) % 256;
            var t = p[q];
            p[q] = p[u];
            p[u] = t
        }
        for (var i = u = q = 0; q < r.length; q++) {
            i = (i + 1) % 256;
            u = (u + p[i]) % 256;
            var t = p[i];
            p[i] = p[u];
            p[u] = t;
            k = p[((p[i] + p[u]) % 256)];
            o += String.fromCharCode(r.charCodeAt(q) ^ k)
        }
        return o
    };

function base64Encode() {
        var C = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", B, A, _, F, D, E;
        _ = G.length;
        A = 0;
        B = "";
        while (A < _) {
            F = G.charCodeAt(A++) & 255;
            if (A == _) {
                B += C.charAt(F >> 2);
                B += C.charAt((F & 3) << 4);
                B += "==";
                break;
            }
            D = G.charCodeAt(A++);
            if (A == _) {
                B += C.charAt(F >> 2);
                B += C.charAt(((F & 3) << 4) | ((D & 240) >> 4));
                B += C.charAt((D & 15) << 2);
                B += "=";
                break;
            }
            E = G.charCodeAt(A++);
            B += C.charAt(F >> 2);
            B += C.charAt(((F & 3) << 4) | ((D & 240) >> 4));
            B += C.charAt(((D & 15) << 2) | ((E & 192) >> 6));
            B += C.charAt(E & 63);
        }
        return B;
    };

G=s(j,r);
console.log(base64Encode(G));


varying highp vec2 textureCoordinate;

uniform sampler2D videoFrame;
uniform mediump float noise;
uniform mediump float uniformPan;
mediump vec4 first;




void main() {
    
    first = texture2D(videoFrame, textureCoordinate);
    first = vec4(first.r + noise,first.g + uniformPan,first.b + uniformPan,1.0);
    gl_FragColor = first;
    gl_FragColor = gl_FragColor.bgra;
//
//    
//    mediump vec4 overlay = vec4(0.98,0.53,0.11,0.10);
//    mediump vec4 base = texture2D(videoFrame, textureCoordinate);
//    mediump float ra;
//    if (2.0 * base.r < base.a) {
//        ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
//    } else {
//        ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
//    }
//    
//    mediump float ga;
//    if (2.0 * base.g < base.a) {
//        ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
//    } else {
//        ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
//    }
//    
//    mediump float ba;
//    if (2.0 * base.b < base.a) {
//        ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
//    } else {
//        ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
//    }
//    
//    
//
//    
//    second = vec4(ra * uniformSecond, ga * uniformSecond, ba * uniformSecond, 1.0);
//    
//    
//    gl_FragColor = vec4(first.r + second.r,first.g +second.g,first.b +second.b,1.0);

    
}


const lowp int GAUSSIAN_SAMPLES = 9;

varying highp vec2 blurCoordinates[GAUSSIAN_SAMPLES];

uniform sampler2D videoFrame;
uniform lowp float testUniform;
uniform highp float uniformBlur;

lowp float first;
lowp float second;
lowp float third;
lowp float map(lowp float x, lowp float in_min, lowp float in_max,lowp float out_min,lowp float out_max){
    return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
}

void main()
{

    first = clamp(0.0,1.0,map(uniformBlur, 0.0, 0.5, 1.0, 0.0));
    
    if (uniformBlur < 0.5) {
        second = clamp(0.0,1.0,map(uniformBlur, 0.0, 0.5, 0.0, 1.0));
    } else {
        second = clamp(0.0,1.0,map(uniformBlur, 0.5, 1.0, 1.0, 0.0));
    }
    
    third = clamp(0.0,1.0,map(uniformBlur, 0.5, 1.0, 0.0, 1.0));
    
    lowp vec4 firstvalue = texture2D(videoFrame, blurCoordinates[0]);
    lowp vec4 secondvalue = texture2D(videoFrame, blurCoordinates[0]);
    lowp vec4 thirdvalue = texture2D(videoFrame, blurCoordinates[0]);
    
    {//FIRST
        firstvalue = vec4(firstvalue.r * first, firstvalue.g * first,firstvalue.b * first ,1.0);
    }
    
    {//SECOND
        mediump vec4 overlay = vec4(0.91,0.5,0.11,0.10);
        mediump vec4 base = secondvalue;
        mediump float ra;
        if (2.0 * base.r < base.a) {
            ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
        } else {
            ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
        }
        
        mediump float ga;
        if (2.0 * base.g < base.a) {
            ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
        } else {
            ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
        }
        
        mediump float ba;
        if (2.0 * base.b < base.a) {
            ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
        } else {
            ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
        }
        
        secondvalue = vec4(ra * second, ga  * second, ba * second, 1.0);
    }

    
    {//THIRD
        thirdvalue = vec4(thirdvalue.r * third, thirdvalue.g * third,thirdvalue.b * third ,1.0);
    }
    


    

    gl_FragColor = vec4(firstvalue.r + secondvalue.r + thirdvalue.r, firstvalue.g + secondvalue.g + thirdvalue.g,firstvalue.b + secondvalue.b + thirdvalue.b,1.0);
    gl_FragColor = gl_FragColor.bgra;
    
}
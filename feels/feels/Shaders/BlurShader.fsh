
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
    
    second = 0.0;
    
    if (uniformBlur < 0.5) {
        second = clamp(0.0,1.0,map(uniformBlur, 0.0, 0.5, 0.0, 1.0));
    } else {
        second = clamp(0.0,1.0,map(uniformBlur, 0.5, 1.0, 1.0, 0.0));
    }
    
    third = clamp(0.0,1.0,map(uniformBlur, 0.5, 1.0, 0.0, 1.0));
    
    gl_FragColor = texture2D(videoFrame, blurCoordinates[0]);
    gl_FragColor = vec4(gl_FragColor.r + first,gl_FragColor.g + second,gl_FragColor.b + third,1.0);
    gl_FragColor = gl_FragColor.bgra;
    
// 	lowp vec4 sum = vec4(0.0);
//
//     sum += texture2D(videoFrame, blurCoordinates[0]) * 0.05;
//     sum += texture2D(videoFrame, blurCoordinates[1]) * 0.09;
//     sum += texture2D(videoFrame, blurCoordinates[2]) * 0.12;
//     sum += texture2D(videoFrame, blurCoordinates[3]) * 0.15;
//     sum += texture2D(videoFrame, blurCoordinates[4]) * 0.18;
//     sum += texture2D(videoFrame, blurCoordinates[5]) * 0.15;
//     sum += texture2D(videoFrame, blurCoordinates[6]) * 0.12;
//     sum += texture2D(videoFrame, blurCoordinates[7]) * 0.09;
//     sum += texture2D(videoFrame, blurCoordinates[8]) * 0.05;
//
//    gl_FragColor = sum;
//
//    gl_FragColor = vec4((sum.rgb + vec3(testUniform)), sum.w);
//    gl_FragColor = gl_FragColor.bgra;
}
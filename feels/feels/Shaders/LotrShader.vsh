attribute vec4 position;
attribute vec4 inputTextureCoordinate;

uniform highp float uniformBlur;
uniform mediump float uniformPan;
uniform mediump float noise;

varying vec2 textureCoordinate;

void main()
{
	gl_Position = position;
	textureCoordinate = inputTextureCoordinate.xy+uniformPan;
}
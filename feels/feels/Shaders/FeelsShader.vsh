attribute vec4 position;
attribute vec4 inputTextureCoordinate;
varying vec2 textureCoordinate;

uniform mediump float noise;
uniform mediump float uniformPan;

void main()
{
	gl_Position = position;
	textureCoordinate = inputTextureCoordinate.xy;
}
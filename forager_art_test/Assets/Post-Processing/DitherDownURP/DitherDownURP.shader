Shader "CustomPostProcessing/DitherDownURP"
{
    SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque" 
			"RenderPipeline" = "UniversalPipeline"
		}

        Pass
        {
            HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag

  
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            TEXTURE2D(_DitherTexture);
            float _Dithering;
            float _Downsampling;
            float _Levels;

            float quantize(float c)
            {
                uint2 levels = _Levels;
                uint2 val = c*255.0;
                val = (((val * levels + 127) / 255) * 255 + levels / 2) / levels;
                
                return val / 255.0;
            } 

			

            float4 frag(Varyings input) : SV_Target
            {
                
                //NOTE TO MICHAEL - Should we do a seperate sample of the input texture instead of _blitTexture then combine input, dither and blit texture to get teh final result?
                // Input sample
                const uint2 pss = (uint2)(input.texcoord * _ScreenSize.xy) / _Downsampling;
                float4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
                
                // Linear -> sRGB
                col.rgb = LinearToSRGB(col.rgb);
                uint tw, th;
                _DitherTexture.GetDimensions(tw, th);
                
                float dither = SAMPLE_TEXTURE2D(_DitherTexture, sampler_LinearClamp, pss % uint2(tw, th)).x;
                
                col.rgb += dither * (_Dithering * 0.5);
                col.r = quantize(col.r);
                col.g = quantize(col.g);
                col.b = quantize(col.b);

                //sRGB -> Linear
                col.rgb = SRGBToLinear(col.rgb);
                return col;
                
            }
            ENDHLSL
        }
        
    } 
}

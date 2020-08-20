Shader "Custom/QChar_1body" {
	Properties{
		_MainTex("MainTexture", 2D) = "white"{}
		//串圖位置
		_TexPos("Texture Pos", Vector) = (0.0, 0.0, 0.0, 0.0)
		//鏡像
		[Toggle] _Mirror("Mirror", float) = 0
		
		//旋轉中心
		_RotCenX("Rotate Center X", float) = 0
		_RotCenY("Rotate Center Y", float) = 0
		//旋轉角度
		_RotateVal("Rotate Value", Vector) = (0.0, 0.0, 0.0, 0.0)

		//動作時間
		_sTimeD("Delay Time", float) = 0			//Time.timeSinceLevelLoad
		//動作速度
		_aSpeed("Action Speed", float) = 1

		_VertScale("VertScale", float) = 1.0

		//頂點(顯示)範圍
		_VertSizeX("VertSizeX", float) = 1.0
		_VertSizeY("VertSizeY", float) = 1.0
	}
	SubShader{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			sampler2D _MainTex;
			fixed4 _TexPos;
			fixed _Mirror;

			fixed _RotCenX, _RotCenY;
			fixed4 _RotateVal;

			fixed _sTimeD;
			fixed _aSpeed;
			fixed _VertScale;

			fixed _VertSizeX, _VertSizeY;

			struct appdata {
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
			};
			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(appdata v) {
				v2f o;
				
				v.vertex.xy *= fixed2(_VertSizeX, _VertSizeY) * _VertScale;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				//鏡像(uv.x顛倒後再加上位移校正)
				o.uv.x = lerp(o.uv.x, 1 - o.uv.x - (1 - (_TexPos.x * 2 + _TexPos.z)), _Mirror);
				return o;
			}

			//頂點和貼圖的大小調整
			fixed2 UVSize(inout fixed2 rUV) {
				fixed2 aVertSpace = fixed2(_VertSizeX, _VertSizeY);
				//fixed2 aImageSpace = fixed2(_ImageSizeX, _ImageSizeY);
				rUV *= aVertSpace;
				rUV += (1 - aVertSpace) * 0.5;
				fixed2 tUV = rUV;
				//fixed2 aSize = 1 / aImageSpace;
				//tUV *= aSize;
				//tUV += (1 - aSize) * 0.5;
				return tUV;
			}

			//顯示範圍處理
			fixed TextureShowRange(fixed2 rUV, fixed4 rTexPos) {
				return step(rTexPos.x, rUV.x) * step(rUV.x, rTexPos.x + rTexPos.z) * step(rTexPos.y, rUV.y) * step(rUV.y, rTexPos.y + rTexPos.w);
			}

			//旋轉UV
			fixed2 RotateUV(fixed2 rUV, fixed2 roCenter, fixed rAngle) {
				fixed2 rotSC;
				sincos(rAngle, rotSC.x, rotSC.y);
				rUV = mul(fixed2x2(rotSC.y, -rotSC.x, rotSC.x, rotSC.y), rUV - roCenter) + roCenter;
				return rUV;
			}			

			fixed4 frag(v2f i) : COLOR {
				fixed nTime = (_Time.y - _sTimeD) * _aSpeed;
				fixed actTime = min(frac(nTime), frac(1 - nTime));

				fixed2 fUV = UVSize(i.uv);
				
				fixed nRotA = lerp(_RotateVal.x, _RotateVal.y, actTime);
				fixed2 rCen = fixed2(_RotCenX, _RotCenY) * _TexPos.zw + _TexPos.xy;
				fUV = RotateUV(fUV, rCen, nRotA);

				fixed4 rCol = tex2D(_MainTex, fUV);
				rCol.a *= TextureShowRange(fUV, _TexPos);
				return rCol;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
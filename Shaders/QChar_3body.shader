Shader "Custom/QChar_3body" {
	Properties{
		_MainTex("MainTexture", 2D) = "white"{}
		//主軸圖位置
		_TexPos("Texture Pos", Vector) = (0.0, 0.0, 0.0, 0.0)
		//副軸圖位置
		_TexSecPos("Texture Second Pos", Vector) = (0.0, 0.0, 0.0, 0.0)
		//x,y:副軸圖位移 z:副軸圖和主軸圖的權重
		_SetSecPandL("Set Tex Second Pos and Lerp", Vector) = (0.0, 0.0, 1.0, 0.0)
		//第三軸位置
		_TexThiPos("Texture Third Pos", Vector) = (0.0, 0.0, 0.0, 0.0)
		//x,y:第三軸位移 z:第三軸和主副軸圖的權重
		_SetThiPandL("Set Tex Third Pos and Lerp", Vector) = (0.0, 0.0, 1.0, 0.0)
		//鏡像
		[Toggle] _Mirror("Mirror", float) = 0

		//主軸旋轉中心
		_RotCenX("Rotate Center X", float) = 0.5
		_RotCenY("Rotate Center Y", float) = 0.5
		//旋轉角度
		_RotateVal("Rotate Value", Vector) = (0.0, 0.0, 0.0, 0.0)
		//副軸旋轉中心
		_RotCenSecX("Rotate Center Second X", float) = 0.5
		_RotCenSecY("Rotate Center Second Y", float) = 0.5
		//副軸旋轉角度
		_RotateSecVal("Rotate Second Value", Vector) = (0.0, 0.0, 0.0, 0.0)
		//第三軸旋轉中心
		_RotCenThiX("Rotate Center Third X", float) = 0.5
		_RotCenThiY("Rotate Center Third Y", float) = 0.5
		//第三軸旋轉角度
		_RotateThiVal("Rotate Third Value", Vector) = (0.0, 0.0, 0.0, 0.0)

		_sTimeD("Delay Time", float) = 0			//Time.timeSinceLevelLoad
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
			fixed4 _TexSecPos;
			fixed4 _SetSecPandL;
			fixed4 _TexThiPos;
			fixed4 _SetThiPandL;
			fixed _Mirror;

			fixed _RotCenX, _RotCenY;
			fixed4 _RotateVal;
			fixed _RotCenSecX, _RotCenSecY;
			fixed4 _RotateSecVal;
			fixed _RotCenThiX, _RotCenThiY;
			fixed4 _RotateThiVal;

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

			//貼圖混合
			fixed4 mixColor(fixed4 aCol, fixed4 bCol, fixed bWeight) {
				return lerp(lerp(bCol, aCol, aCol.a), lerp(aCol, bCol, bCol.a), bWeight);
			}

			fixed4 frag(v2f i) : COLOR {
				fixed nTime = (_Time.y - _sTimeD) * _aSpeed;
				fixed actTime = min(frac(nTime), frac(1 - nTime));
				//==============第一張圖=============
				fixed2 fUV = UVSize(i.uv);

				fixed nRotA = lerp(_RotateVal.x, _RotateVal.y, actTime);
				fixed2 rCen = fixed2(_RotCenX, _RotCenY) * _TexPos.zw + _TexPos.xy;
				fUV = RotateUV(fUV, rCen, nRotA);

				fixed4 fCol = tex2D(_MainTex, fUV);
				fCol.a *= TextureShowRange(fUV, _TexPos);
				//===================================
				//==============第二張圖=============
				fixed2 sUV = fUV + _SetSecPandL.xy * _TexSecPos.zw;

				fixed nsRotA = lerp(_RotateSecVal.x, _RotateSecVal.y, actTime);
				fixed2 rsecOneCen = fixed2(_RotCenSecX, _RotCenSecY) * _TexSecPos.zw + _TexSecPos.xy;
				sUV = RotateUV(sUV, rsecOneCen, nsRotA);

				fixed4 sCol = tex2D(_MainTex, sUV);
				sCol.a *= TextureShowRange(sUV, _TexSecPos);
				//===================================
				//==============第三張圖=============
				fixed2 tUV = sUV + _SetThiPandL.xy * _TexThiPos.zw;

				fixed ntRotA = lerp(_RotateThiVal.x, _RotateThiVal.y, actTime);
				fixed2 rthiOneCen = fixed2(_RotCenThiX, _RotCenThiY) * _TexThiPos.zw + _TexThiPos.xy;
				tUV = RotateUV(tUV, rthiOneCen, ntRotA);

				fixed4 tCol = tex2D(_MainTex, tUV);
				tCol.a *= TextureShowRange(tUV, _TexThiPos);
				//===================================
				fixed4 rCol = mixColor(fCol, sCol, _SetSecPandL.z);
				rCol = mixColor(rCol, tCol, _SetThiPandL.z);

				return rCol;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}

Shader "Custom/UI/MaskedGreyscale"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _DragPos ("Draggable Position", Vector) = (0,0,0,0)
        _DragSize ("Draggable Size", Vector) = (0,0,0,0)
        _ShapeMask ("Shape Mask", 2D) = "white" {} // Added property for shape mask texture
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _DragPos;
            float4 _DragSize;
            sampler2D _ShapeMask; // Added sampler for shape mask texture

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
    // Convert the draggable image's rectangle from screen-space to texture-space
    float2 texCoords = i.uv - _DragPos.xy;
    texCoords /= _DragSize.xy;

    // Check if the pixel is inside the draggable image
    if (texCoords.x >= 0 && texCoords.y >= 0 && texCoords.x <= 1 && texCoords.y <= 1)
    {
        // Sample from the correct position in the main texture
        fixed4 col = tex2D(_MainTex, texCoords);
        fixed4 maskCol = tex2D(_MaskTex, texCoords);

        // Sample the shape mask using the original texture coordinates
        fixed4 shapeMask = tex2D(_ShapeMask, i.uv);

        // If the pixel is outside the shape defined by the shape mask, discard it
        if (shapeMask.a < 0.5) // Outside the shape
        {
            discard; // Do not render this pixel
        }

        // Convert to greyscale
        float grey = dot(col.rgb, float3(0.3, 0.59, 0.11));

        // Check the mask color
        if (maskCol.r > 0.5) // Red in mask - make it black
        {
            return fixed4(0, 0, 0, 1);
        }
        else if (maskCol.g > 0.5) // Green in mask - make it grayscale
        {
            return fixed4(grey, grey, grey, 1);
        }
        else // No mask - return original color
        {
            return col;
        }
    }
    else
    {
        return fixed4(1, 1, 1, 0); // Transparent color outside the draggable image
    }
            }
            ENDCG
        }
    }
}

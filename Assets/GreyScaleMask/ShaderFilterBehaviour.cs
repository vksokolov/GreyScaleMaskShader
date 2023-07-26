using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace ShaderTest
{
    [ExecuteInEditMode]
    public class ShaderFilterBehaviour : MonoBehaviour, IPointerDownHandler, IDragHandler
    {
        public RectTransform parentRect;
        public Texture2D shapeMask; 
        public bool ExecuteInEditor;
        
        private Material material;
        private RectTransform filterRect;

        void Start()
        {
            // Get the RectTransform and Material
            filterRect = GetComponent<RectTransform>();
            material = GetComponent<Image>().material;

            if (material == null || filterRect == null)
            {
                Debug.LogError("Failed to get Material or RectTransform");
            }
        }

        void Update()
        {
            if (!ExecuteInEditor)
                return;
            
            var parentSize = parentRect.rect.size;
            var filterSize = filterRect.rect.size;
    
            var relativeSize = new Vector2(parentSize.x / filterSize.x, parentSize.y / filterSize.y);
            
            var parentRectPosition = parentRect.position;
            Vector2 parentBottomLeft = parentRectPosition - new Vector3(parentSize.x, parentSize.y) / 2;
            Vector2 parentTopRight = parentRectPosition + new Vector3(parentSize.x, parentSize.y) / 2;

            var maxFilterBottomLeft = parentBottomLeft + new Vector2(filterSize.x, filterSize.y) / 2;
            var maxFilterTopRight = parentTopRight - new Vector2(filterSize.x, filterSize.y) / 2;

            var filterRectPosition = filterRect.position;
            var relativePos = new Vector2(
                1 - InverseLerpUnclamped(maxFilterBottomLeft.x, maxFilterTopRight.x, filterRectPosition.x),
                1 - InverseLerpUnclamped(maxFilterBottomLeft.y, maxFilterTopRight.y, filterRectPosition.y)
            );

            relativePos.x = Mathf.LerpUnclamped(1 - relativeSize.x, 0, relativePos.x);
            relativePos.y = Mathf.LerpUnclamped(1 - relativeSize.y, 0, relativePos.y);

            material.SetVector("_DragPos", relativePos);
            material.SetVector("_DragSize", relativeSize);
            material.SetTexture("_ShapeMask", shapeMask);
            
        }








        public void OnPointerDown(PointerEventData eventData)
        {
            // Pass the drag event to the OnDrag function
            OnDrag(eventData);
        }

        public void OnDrag(PointerEventData eventData)
        {
            // Update the position of the draggable image
            filterRect.position += new Vector3(eventData.delta.x, eventData.delta.y);
        }
        
        public static float InverseLerpUnclamped( float a, float b, float value) => (value - a) / (b - a);
    }
}

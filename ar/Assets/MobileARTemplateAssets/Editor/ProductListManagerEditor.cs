using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ProductListManager))]
public class ProductListManagerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(8);

        ProductListManager manager = (ProductListManager)target;

        using (new EditorGUI.DisabledScope(Application.isPlaying))
        {
            if (GUILayout.Button("Preview Mock Data In Editor"))
            {
                manager.PreviewMockDataInEditor();
            }

            if (GUILayout.Button("Clear Preview Items"))
            {
                manager.ClearPreviewItems();
            }
        }
    }
}

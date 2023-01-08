using UnityEditor;
using UnityEditor.Rendering.PostProcessing;

namespace SCPE
{
    [PostProcessEditor(typeof(Pixelize))]
    public sealed class PixelizeEditor : PostProcessEffectEditor<Pixelize>
    {
        SerializedParameterOverride amount;
        SerializedParameterOverride resolutionPreset;
        SerializedParameterOverride resolution;

        public override void OnEnable()
        {
            amount = FindParameterOverride(x => x.amount);
            resolutionPreset = FindParameterOverride(x => x.resolutionPreset);
            resolution = FindParameterOverride(x => x.resolution);
        }

        public override void OnInspectorGUI()
        {
            SCPE_GUI.DisplayDocumentationButton("pixelize");

            SCPE_GUI.DisplaySetupWarning<PixelizeRenderer>();

            PropertyField(amount);
            SCPE_GUI.DisplayIntensityWarning(amount);
            
            PropertyField(resolutionPreset);
            if (resolutionPreset.value.intValue == (int)Pixelize.Resolution.Custom)
            {
                EditorGUI.indentLevel++;
                PropertyField(resolution);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.Space();
        }
    }
}
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

namespace SCPE
{
    public sealed class PixelizeRenderer : PostProcessEffectRenderer<Pixelize>
    {
        Shader shader;

        public override void Init()
        {
            shader = Shader.Find(ShaderNames.Pixelize);
        }

        private static readonly int _Scale = Shader.PropertyToID("_Scale");
        private static readonly int _PixelScale = Shader.PropertyToID("_PixelScale");
        private static readonly int _Resolution = Shader.PropertyToID("_Resolution");
        
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(shader);

            var resolution = settings.resolutionPreset.value == Pixelize.Resolution.Custom ? settings.resolution.value : (int)settings.resolutionPreset.value;

            sheet.properties.SetFloat(_Scale, settings.amount.value);
            sheet.properties.SetFloat(_PixelScale, context.screenHeight / (float)resolution);
            sheet.properties.SetInt(_Resolution, (int)resolution);

            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}
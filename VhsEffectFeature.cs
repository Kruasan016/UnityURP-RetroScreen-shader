using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class VhsEffectFeature : ScriptableRendererFeature
{
    class VhsPass : ScriptableRenderPass
    {
        RTHandle _sourceHandle;
        Material _material;
        const string k_ProfilingTag = "VHS Effect";

        public VhsPass(Material mat)
        {
            _material = mat;
            renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData data)
        {
            _sourceHandle = data.cameraData.renderer.cameraColorTargetHandle;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData data)
        {
            var camera = data.cameraData.camera;
            if (camera.cameraType == CameraType.Preview)
                return;
            if (_material == null)
                return;

            var cmd = CommandBufferPool.Get(k_ProfilingTag);
            Blitter.BlitCameraTexture(cmd, _sourceHandle, _sourceHandle, _material, 0);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }
    }

    [System.Serializable]
    public class VhsSettings
    {
        public Material material = null;
    }

    public VhsSettings settings = new VhsSettings();
    VhsPass _pass;

    public override void Create()
    {
        if (settings.material != null)
            _pass = new VhsPass(settings.material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData data)
    {
        if (_pass != null)
            renderer.EnqueuePass(_pass);
    }
}

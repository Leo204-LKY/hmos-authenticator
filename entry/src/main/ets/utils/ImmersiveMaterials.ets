import { uiMaterial } from '@kit.ArkUI';

const buttonLightEffect: uiMaterial.LightEffectOptions = { color: Color.White };

let iconButtonMaterial: uiMaterial.ImmersiveMaterial | undefined = undefined;
let textButtonMaterial: uiMaterial.ImmersiveMaterial | undefined = undefined;
let warningButtonMaterial: uiMaterial.ImmersiveMaterial | undefined = undefined;
let switchMaterial: uiMaterial.ImmersiveMaterial | undefined = undefined;

/**
 * 圆形图标按钮（标题栏菜单、滑动操作按钮）的沉浸光感材质：
 * 超薄材质 + 交互形变 + 光感按压反馈。
 */
export function getIconButtonImmersiveMaterial(): uiMaterial.ImmersiveMaterial | undefined {
  if (!uiMaterial.isImmersiveMaterialSupported()) {
    return undefined;
  }
  if (iconButtonMaterial === undefined) {
    iconButtonMaterial = new uiMaterial.ImmersiveMaterial({
      style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
      interactive: true,
      lightEffect: buttonLightEffect
    });
  }
  return iconButtonMaterial;
}

/**
 * 普通文字按钮（NORMAL 风格）的沉浸光感材质：
 * 薄材质 + 交互形变 + 光感按压反馈。
 */
export function getTextButtonImmersiveMaterial(): uiMaterial.ImmersiveMaterial | undefined {
  if (!uiMaterial.isImmersiveMaterialSupported()) {
    return undefined;
  }
  if (textButtonMaterial === undefined) {
    textButtonMaterial = new uiMaterial.ImmersiveMaterial({
      style: uiMaterial.ImmersiveStyle.THIN,
      interactive: true,
      lightEffect: buttonLightEffect
    });
  }
  return textButtonMaterial;
}

/**
 * 删除等警示操作的沉浸光感材质：
 * 超薄材质叠加半透明警示色，保留破坏性操作的视觉语义。
 */
export function getWarningButtonImmersiveMaterial(): uiMaterial.ImmersiveMaterial | undefined {
  if (!uiMaterial.isImmersiveMaterialSupported()) {
    return undefined;
  }
  if (warningButtonMaterial === undefined) {
    warningButtonMaterial = new uiMaterial.ImmersiveMaterial({
      style: uiMaterial.ImmersiveStyle.ULTRA_THIN,
      materialColor: $r('app.color.warning_material'),
      interactive: true,
      lightEffect: buttonLightEffect
    });
  }
  return warningButtonMaterial;
}

/**
 * Switch 型 Toggle 的沉浸光感开启标记：
 * 材质参数不影响实际视觉效果，由组件内部预设视觉参数呈现。
 */
export function getSwitchImmersiveMaterial(): uiMaterial.ImmersiveMaterial | undefined {
  if (!uiMaterial.isImmersiveMaterialSupported()) {
    return undefined;
  }
  if (switchMaterial === undefined) {
    switchMaterial = new uiMaterial.ImmersiveMaterial();
  }
  return switchMaterial;
}

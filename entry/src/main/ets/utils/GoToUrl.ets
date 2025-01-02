import { common, Want } from "@kit.AbilityKit";

export function goToUrl(component: Object, url: string) {
  let context = getContext(component) as common.UIAbilityContext;
  let want: Want = {
    action: 'ohos.want.action.viewData',
    uri: url
  };
  context.startAbility(want);
}
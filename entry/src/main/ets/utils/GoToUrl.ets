import { common, Want } from "@kit.AbilityKit";

export function goToUrl(context: common.UIAbilityContext, url: string) {
  let want: Want = {
    action: 'ohos.want.action.viewData',
    uri: url
  };
  context.startAbility(want);
}
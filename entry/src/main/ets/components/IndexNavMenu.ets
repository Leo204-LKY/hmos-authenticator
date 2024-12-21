import { buildAddMenuOptions } from '../models/AddMenuOptionBuilder';
import { Preferences } from '../models/Preferences';
import { promptAction } from '@kit.ArkUI';

const preferences = Preferences.getInstance();

@Builder
export function buildIndexNavMenu() {
  IndexNavMenu()
    .height(40)
    .margin({ top: 8, bottom: 8, right: 16 })
}

@Preview
@Component
struct IndexNavMenu {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    Row({space: 8}) {
      this.MenuButton($r('app.media.ic_public_add'), undefined, buildAddMenuOptions(getContext(this), this.navPathStack))
      // this.MenuButton($r('app.media.ic_public_search'))  // TODO: 搜索页面
      this.MenuButton($r('app.media.ic_public_more'), undefined, this.moreMenu)
    }
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  MenuButton(image: ResourceStr, onClick?: () => void, bindMenu?: Array<MenuElement>) {
    Button() {
      Image(image)
        .height(24)
        .width(24)
        .fillColor($r('app.color.text_primary'))
    }
    .height(40)
    .width(40)
    .type(ButtonType.Circle)
    .buttonStyle(ButtonStyleMode.NORMAL)
    .align(Alignment.Center)
    .onClick(onClick)
    .bindMenu(bindMenu)
  }

  private sortItem = () => {
    let authenticatorCount = (preferences.getSync('authenticatorSequence', []) as number[]).length;

    if (authenticatorCount == 0) {
      promptAction.showToast({
        message: $r('app.string.mainPageMenu_noAuthenticatorToast'),
        duration: 3000
      })
    } else {
      this.navPathStack.pushPath({ name: 'SortPage' })
    }
  }

  private moreMenu: Array<MenuElement> = [
    {
      value: $r('app.string.mainPageMenu_sort'),
      icon: $r('app.media.ic_public_view_list'),
      action: this.sortItem
    },
    {
      value: $r('app.string.mainPageMenu_settings'),
      icon: $r('app.media.gearshape'),
      action: () => { this.navPathStack.pushPath({ name: 'SettingsPage' })}
    }
  ]
}
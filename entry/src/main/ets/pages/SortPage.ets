import { EditableLeftIconType, EditableTitleBar } from '@ohos.arkui.advanced.EditableTitleBar';
import { AuthenticatorClass } from '../models/AuthenticatorClass';
import { SortPageAuthenticatorItem } from '../components/SortPageAuthenticatorItem'
import { Preferences } from '../models/Preferences';

const preferences = Preferences.getInstance();

export class SortPageParams {
  private _authenticators: AuthenticatorClass[];

  constructor(authenticators: AuthenticatorClass[]) {
    this._authenticators = authenticators;
  }

  get authenticators(): AuthenticatorClass[] { return this._authenticators };
}

@Builder
export function sortPageBuilder() {
  SortPage()
}

@Entry
@Component
struct SortPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @State authenticators: AuthenticatorClass[] = [];
  @State dragItem: AuthenticatorClass | null = null;
  @State scaleItem: AuthenticatorClass | null = null;
  @State neighbourItem: AuthenticatorClass | null = null;
  @State neighbourScale: number = -1;
  @State dragRefOffset: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State ITEM_INTV: number = 77;    // ListItem 高度（包含 margin） + 每个 ListItem 间隙的一半
  @State edited: boolean = false;

  build() {
    NavDestination() {
      Column() {
        EditableTitleBar({
          leftIconStyle: EditableLeftIconType.Cancel,
          title: $r('app.string.SortPage_title'),
          onSave: () => {
            let newSequence: number[] = [];

            for (let i = 0; i < this.authenticators.length; i++) {
              newSequence.push(this.authenticators[i].id)
            }

            preferences.set('authenticatorSequence', newSequence)
              .then(() => { this.navPathStack.pop(); })
          },
          onCancel: () => {
            this.navPathStack.pop();
          }
        })

        Scroll() {
          Column() {
            Text($r('app.string.SortPage_hint'))
              .textAlign(TextAlign.Center)
              .margin({ top: 16, bottom: 4 })

            List({ space: 10, initialIndex: 0 }) {
              ForEach(
                this.authenticators,
                (item: AuthenticatorClass) => {
                  SortPageAuthenticatorItem({
                    item: item,
                    authenticators: this.authenticators,
                    dragItem: this.dragItem,
                    scaleItem: this.scaleItem,
                    neighbourItem: this.neighbourItem,
                    neighbourScale: this.neighbourScale,
                    dragRefOffset: this.dragRefOffset,
                    offsetX: this.offsetX,
                    offsetY: this.offsetY,
                    ITEM_INTV: this.ITEM_INTV,
                    getItemIndex: this.getItemIndex,
                    getScale: this.getScale,
                    getZIndex: this.getZIndex,
                    itemMove: this.itemMove
                  })
                },
                (item: AuthenticatorClass) => item.id.toString()
              )
            }
            .width('100%')
            .height('100%')
            .listDirection(Axis.Vertical)
            .alignListItem(ListItemAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.gray_01'))
  }

  aboutToAppear(): void {
    let sortPageParams = this.navPathStack.getParamByIndex(0) as SortPageParams;
    this.authenticators = sortPageParams.authenticators;
  }

  getItemIndex(itemId: number): number {
    for (let i = 0; i < this.authenticators.length; i++) {
      if (itemId == this.authenticators[i].id) {
        return i;
      }
    }
    return -1;
  }

  getScale(item: AuthenticatorClass): number {
    if (this.scaleItem?.id === item.id) {
      return 1.05;
    } else if (this.neighbourItem?.id === item.id) {
      return this.neighbourScale;
    } else {
      return 1;
    }
  }

  getZIndex(item: AuthenticatorClass): number {
    return (this.dragItem?.id === item.id) ? 1 : 0;
  }

  itemMove(index: number, newIndex: number): void {
    let tmpAuthenticator = this.authenticators.splice(index, 1);
    this.authenticators.splice(newIndex, 0, tmpAuthenticator[0]);
    this.edited = true;
  }
}
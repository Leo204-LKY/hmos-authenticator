import { AuthenticatorClass } from '../models/AuthenticatorClass'
import { curves } from '@kit.ArkUI';

@Component
export struct SortPageAuthenticatorItem {
  @Require @Prop item: AuthenticatorClass;
  @Link authenticators: AuthenticatorClass[];
  @Link dragItem: AuthenticatorClass | null;
  @Link scaleItem: AuthenticatorClass | null;
  @Link neighbourItem: AuthenticatorClass | null;
  @Link neighbourScale: number;
  @Link dragRefOffset: number;
  @Link offsetX: number;
  @Link offsetY: number;
  @Link ITEM_INTV: number;
  @Link edited: boolean;
  @Require getItemIndex: Function = () => {};
  @Require getScale: Function = () => {};
  @Require getZIndex: Function = () => {};
  @Require itemMove: Function = () => {};
  @Prop authenticatorId: number;
  @Prop issuer: string;
  @Prop account: string | null;

  build() {
    ListItem() {
      Column() {
        Row() {
          Column() {
            Text(this.issuer)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
            Text(this.account)
              .fontSize(16)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Image($r('app.media.ic_public_drag_handle'))
            .size({ width: 24, height: 24 })
            .fillColor($r('app.color.text_primary'))
            .draggable(false)
        }
      }
    }
    .height(72)
    .backgroundColor($r('app.color.background_secondary'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
    .margin({ left: 16, right: 16, top: this.getItemIndex(this.authenticatorId) === 0 ? 16 : 0 })
    .scale({ x: this.getScale(this.item), y: this.getScale(this.item) })
    .zIndex(this.getZIndex(this.item))
    .translate({ y: (this.dragItem?.id === this.authenticatorId) ? this.offsetY : 0 })
    .shadow({
      radius: (this.dragItem?.id == this.authenticatorId) ? 70 : 0,
      color: $r("app.color.shadow")
    })
    .gesture(
      GestureGroup(
        GestureMode.Sequence,
        LongPressGesture({ repeat: true })
          .onAction((_: GestureEvent) => {
            animateTo({ curve: Curve.Friction, duration: 300 }, () => {
              this.scaleItem = this.item;
            })
          })
          .onActionEnd((_: GestureEvent) => {
            animateTo({ curve: Curve.Friction, duration: 300 }, () => {
              this.scaleItem = null;
            })
          }),
        PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 0 })
          .onActionStart((_: GestureEvent) => {
            this.dragItem = this.item;
            this.dragRefOffset = 0;
          })
          .onActionUpdate((event: GestureEvent) => {
            this.offsetY = event.offsetY - this.dragRefOffset;
            this.neighbourItem = null;
            let index: number = this.getItemIndex(this.authenticatorId);
            let curveValue = curves.initCurve(Curve.Sharp);
            let value = 0;

            // 根据位移计算相邻项的缩放
            if (this.offsetY < 0) {
              value = curveValue.interpolate(-this.offsetY / this.ITEM_INTV);
              this.neighbourItem = this.authenticators[index-1];
              this.neighbourScale = 1 - value / 20.;
            } else if (this.offsetY > 0) {
              value = curveValue.interpolate(this.offsetY / this.ITEM_INTV);
              this.neighbourItem = this.authenticators[index+1];
              this.neighbourScale = 1 - value / 20;
            }

            // 根据位移交换排序
            if ((this.offsetY > this.ITEM_INTV / 2) && (index + 1 < this.authenticators.length)) {
              animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                this.offsetY -= this.ITEM_INTV;
                this.dragRefOffset += this.ITEM_INTV;
                this.itemMove(index, index + 1);
                this.edited = true;
              })
            } else if ((this.offsetY < -this.ITEM_INTV / 2) && (index > 0)) {
              animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
                this.offsetY += this.ITEM_INTV;
                this.dragRefOffset -= this.ITEM_INTV;
                this.itemMove(index, index - 1);
                this.edited = true;
              })
            }
          })
          .onActionEnd((_: GestureEvent) => {
            animateTo({ curve: curves.interpolatingSpring(0, 1, 400, 38) }, () => {
              this.dragItem = null;
              this.neighbourItem = null;
            })
            animateTo({ curve: curves.interpolatingSpring(14, 1, 170, 17), delay: 150 }, () => {
              this.scaleItem = null;
            })
          })
      )
    )
  }

  aboutToAppear() {
    this.authenticatorId = this.item.id
    this.issuer = this.item.issuer;
    this.account = this.item.account;
  }
}
import { AuthenticatorClass } from '../models/AuthenticatorClass'
import { EditPageParams } from '../pages/EditPage';
import { ConfirmRemoveDialog } from './ConfirmRemoveDialog'

@Component
export struct AuthenticatorItem {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @Require @Prop authenticator: AuthenticatorClass
  @Prop authenticatorId: number;
  @Prop issuer: string;
  @Prop account: string | null;
  @Prop code: string = '';
  @Prop updateInterval: number;
  @Prop timeLeft: number;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: ConfirmRemoveDialog({
      confirm: () => { this.deleteAuthenticator(); },
      authenticatorName: this.issuer
    }),
  })

  @Builder
  itemSwipeOption() {
    Row({ space: 10 }) {
      Button() {
        SymbolGlyph($r('sys.symbol.square_and_pencil'))
          .fontColor([$r('app.color.text_primary')])
          .fontSize(24)
      }
      .type(ButtonType.Circle)
      .backgroundColor($r('app.color.background_secondary'))
      .align(Alignment.Center)
      .padding(8)
      .height('100%')
      .onClick(() => {
        this.navPathStack.pushPath({ name: 'EditPage', param: new EditPageParams(this.authenticator) })
      })

      Button() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontColor([$r('app.color.white')])
          .fontSize(24)
      }
      .type(ButtonType.Circle)
      .backgroundColor($r('app.color.warning'))
      .align(Alignment.Center)
      .padding(8)
      .height('100%')
      .onClick(() => {
        if (this.dialogController != null) {
          this.dialogController.open();
        }
      })
    }
    .height('50%')
    .margin({ right: 16 })
  }

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

          Text(this.code)
            .fontWeight(600)
            .fontSize(32)
        }

        Blank()
          .height(8)

        Progress({ value: 0, total: this.updateInterval, type: ProgressType.Linear })
          .height(4)
          .value(this.timeLeft)
      }
      .backgroundColor($r('app.color.background_secondary'))
      .borderRadius(16)
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
      .margin({
        left: 16,
        right: 16
      })
    }
    .swipeAction({
      end: {
        builder: () => { this.itemSwipeOption() }
      }
    })
  }

  aboutToAppear() {
    this.authenticatorId = this.authenticator.id
    this.issuer = this.authenticator.issuer;
    this.account = this.authenticator.account;
    this.updateInterval = this.authenticator.updateInterval;
    this.authenticator.getCode()
      .then((code: string) => {
        this.code = code;
      })
    this.updateTimeLeft(Math.floor(Date.now() / 1000))

    getContext(this).eventHub.on('onEmitTimestamp', (timestamp: number) => {
      this.updateTimeLeft(timestamp)
    });
  }

  aboutToDisappear(): void {
    this.dialogController = null; // 在即将析构销毁时将 dialogController 置空
  }

  private updateTimeLeft(timestamp: number) {
    this.timeLeft = this.updateInterval - (timestamp % this.updateInterval);

    if (this.timeLeft === this.updateInterval) {
      this.authenticator.getCode()
        .then((code) => {
          this.code = code;
        })
    }
  }

  private deleteAuthenticator() {
    getContext(this).eventHub.emit('onDeleteAuthenticator', this.authenticatorId);
  }
}
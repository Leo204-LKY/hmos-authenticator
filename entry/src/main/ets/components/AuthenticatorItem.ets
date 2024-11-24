import { AuthenticatorClass } from '../models/AuthenticatorClass'

@Component
export struct AuthenticatorItem {
  @Require @Prop authenticator: AuthenticatorClass
  @Prop issuer: string;
  @Prop account: string | null;
  @Prop code: string = '';
  @Prop updateInterval: number;
  @Prop timeLeft: number;

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
              .fontSize(15)
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
          .height(4)

        Progress({ value: 0, total: this.updateInterval, type: ProgressType.Linear })
          .height(2)
          .value(this.timeLeft)
      }
      .backgroundColor('white')
      .borderRadius(16)
      .width('95%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
    }
  }

  aboutToAppear() {
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

  updateTimeLeft(timestamp: number) {
    this.timeLeft = this.updateInterval - (timestamp % this.updateInterval);

    if (this.timeLeft === this.updateInterval) {
      this.authenticator.getCode()
        .then((code) => {
          this.code = code;
        })
    }
  }
}
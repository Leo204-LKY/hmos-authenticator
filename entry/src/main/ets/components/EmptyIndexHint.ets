import { buildAddMenuOptions } from '../models/AddMenuOptionBuilder';

@Preview
@Component
export struct EmptyIndexHint {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    Column() {
      SymbolGlyph($r('sys.symbol.square_grid_2x2'))
        .fontColor([$r('app.color.text_secondary')])
        .fontSize(120)
        .margin({ bottom: 12 })

      Text($r('app.string.EmptyIndexHint_mainText'))
        .fontColor($r('app.color.text_secondary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 12, bottom: 12 })

      Button($r('app.string.EmptyIndexHint_addButtonText'))
        .buttonStyle(ButtonStyleMode.NORMAL)
        .margin({ top: 12 })
        .bindMenu(buildAddMenuOptions(getContext(this), this.navPathStack))
    }
    .alignItems(HorizontalAlign.Center)
  }
}
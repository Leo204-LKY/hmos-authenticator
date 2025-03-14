@Component
export struct LabelledSelect {
  @State label: ResourceStr = 'Label';
  @State selectEnabled: boolean = true;
  @Link selectedIndex: number;
  @Link value: ResourceStr;
  @State selectOption: Array<SelectOption> = [];
  @State noSelectMessage: ResourceStr = $r('app.string.LabelledSelect_defaultNoSelectMessage')
  onSelect: () => void = () => {};

  aboutToAppear() {
    if (this.selectedIndex == -1) {
      this.value = this.noSelectMessage;
    } else if (this.selectOption.length != 0) {
      this.value = this.selectOption[this.selectedIndex]['value']
    }
  }

  build() {
    Column({ space: 5 }) {
      Text(this.label)
        .offset({ left: 16, right: 16 })
        .fontColor(this.selectEnabled ? $r('app.color.text_primary') : $r('app.color.text_disabled'))
      Select(this.selectOption)
        .width('100%')
        .selected(this.selectedIndex)
        .value(this.value)
        .enabled(this.selectEnabled)
        .onSelect((index: number, value?: string) => {
          this.selectedIndex = index;
          if (value) {
            this.value = value;
          }
          this.onSelect();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
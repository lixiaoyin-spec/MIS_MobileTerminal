import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserStore } from '../store/UserStore';
import common from '@ohos.app.ability.common';
// 从纯 TS 文件导入 BusinessError，而非自己定义
import { BusinessError } from '../common/ErrorTypes';

@Entry
@Component
struct LoginPage {
  @State username: string = "";
  @State password: string = "";
  @State message: string = "";
  @State loading: boolean = false;

  @State private store?: UserStore = new(UserStore);

  async aboutToAppear() {
    const s = new UserStore();
    await s.init(getContext(this) as common.Context);
    this.store = s;

    if (s.isLoggedIn()) {
      router.replaceUrl({ url: "pages/Home" });
    }
  }

  async onLoginClick() {
    // 基础校验
    if (!this.username || !this.password) {
      this.message = "用户名或密码不能为空";
      promptAction.showToast({ message: this.message });
      return;
    }
    if (!this.store) {
      this.message = "初始化未完成，请重试";
      promptAction.showToast({ message: this.message });
      return;
    }

    this.loading = true;
    this.message = "";
    try {
      const res = await this.store.login(this.username, this.password);
      promptAction.showToast({ message: res.msg || "登录成功" });
      router.replaceUrl({ url: "pages/Home" });
    } catch (err) {
      let errorMsg = "登录失败：用户名或密码错误";
      // 仅用 instanceof 判断（符合 ArkTS 规则）
      if (err instanceof BusinessError) {
        errorMsg = err.message || errorMsg;
      } else if (err instanceof Error) {
        errorMsg = err.message;
      } else {
        errorMsg = "登录失败：网络异常";
      }

      console.error("登录失败", err);
      this.message = errorMsg;
      promptAction.showToast({ message: errorMsg });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column({ space: 20 }) {
      Text("学伴领航")
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60 })

      TextInput({ placeholder: "用户名", text: this.username })
        .width("80%")
        .onChange((v: string) => {
          this.username = v;
          this.message = "";
        })

      TextInput({ placeholder: "密码", text: this.password })
        .width("80%")
        .type(InputType.Password)
        .onChange((v: string) => {
          this.password = v;
          this.message = "";
        })

      Button(this.loading ? "登录中..." : "登录")
        .width("60%")
        .enabled(!this.loading)
        .backgroundColor(this.loading ? Color.Grey : Color.Blue)
        .onClick(() => { this.onLoginClick(); })

      Button("去注册")
        .width("60%")
        .onClick(() => { router.pushUrl({ url: "pages/Register" }); })

      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(Color.Red)
          .margin({ top: 10 })
      }
    }
    .width("100%")
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Center);
  }
}
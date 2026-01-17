import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { UserStore } from '../store/UserStore';
import common from '@ohos.app.ability.common';

// 1. 自定义业务错误类（继承原生 Error，支持 instanceof 判断）
export class BusinessError extends Error {
  code?: number; // 可选错误码
  constructor(message: string, code?: number) {
    super(message);
    this.code = code;
    this.name = 'BusinessError'; // 标记错误类型
  }
}

@Entry
@Component
struct LoginPage {
  @State username: string = "";
  @State password: string = "";
  @State message: string = "";
  @State loading: boolean = false;

  @State private store?: UserStore = new(UserStore);

  // 页面第一次显示时初始化 store
  async aboutToAppear() {
    const s = new UserStore();
    await s.init(getContext(this) as common.Context);
    this.store = s;

    // 如果之前已登录，直接跳转 Home
    this.store?.logout();
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
      // 调用登录方法
      const res = await this.store.login(this.username, this.password);
      AppStorage.setOrCreate("token", res.data.token);
      router.replaceUrl({ url: "pages/Home" });
    } catch (err) { // 无类型注解，符合 arkts-no-types-in-catch
      // 2. 仅用 instanceof 判断类型，避免 is/in/unknown
      let errorMsg = "登录失败：用户名或密码错误";

      // 优先判断自定义业务错误
      if (err instanceof BusinessError) {
        errorMsg = err.message || errorMsg;
      }
      // 兼容原生 Error 对象
      else if (err instanceof Error) {
        errorMsg = err.message;
      }
      // 兜底处理（ArkTS 中 catch 的 err 基本都是 Error 实例）
      else {
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
    Stack() {
      // 1. 背景层：静态深蓝渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[0x1e3c72, 0.0], [0x2a5298, 1.0]]
        })

      // 2. 内容层：玻璃拟态卡片
      Column({ space: 20 }) {
        Text("学伴领航")
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .margin({ top: 10, bottom: 20 })
          .letterSpacing(2)

        TextInput({ placeholder: "用户名", text: this.username })
          .width("100%")
          .height(48)
          .backgroundColor('#F5F7FA')
          .borderRadius(8)
          .padding({ left: 16 })
          .onChange((v: string) => {
            this.username = v;
            this.message = ""; // 输入时清空错误提示
          })

        TextInput({ placeholder: "密码", text: this.password })
          .width("100%")
          .height(48)
          .backgroundColor('#F5F7FA')
          .borderRadius(8)
          .type(InputType.Password)
          .padding({ left: 16 })
          .onChange((v: string) => {
            this.password = v;
            this.message = ""; // 输入时清空错误提示
          })

        // 登录按钮
        Button(this.loading ? "登录中..." : "登录")
          .width("100%")
          .height(48)
          .enabled(!this.loading)
          .backgroundColor(this.loading ? '#A0CFFF' : '#007DFF')
          .borderRadius(8)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .shadow({ radius: 8, color: "rgba(0, 125, 255, 0.3)", offsetY: 4 })
          .onClick(() => { this.onLoginClick(); })

        // 去注册按钮
        Button("没有账号？去注册")
          .width("100%")
          .backgroundColor(Color.Transparent)
          .fontColor('#666')
          .fontSize(14)
          .onClick(() => { router.pushUrl({ url: "pages/Register" }); })

        // 错误提示
        if (this.message) {
          Text(this.message)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .margin({ top: 5 })
        }
      }
      .width("85%")
      .padding({ top: 40, bottom: 40, left: 30, right: 30 })
      .backgroundColor('rgba(255, 255, 255, 0.9)') // 半透明白
      .borderRadius(16)
      .shadow({ radius: 30, color: 'rgba(31, 38, 135, 0.25)', offsetY: 10 })
      // .backdropBlur(10) // 注意：部分设备/版本可能不支持，视情况而定，这里主要靠背景色透明度模拟
    }
    .width('100%')
    .height('100%')
  }
}

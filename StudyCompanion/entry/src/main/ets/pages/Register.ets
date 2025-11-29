import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { RegisterResponse } from '../store/UserStore'; // 复用UserStore里的注册响应接口
import { BusinessError } from '../common/ErrorTypes';
import { print } from '@kit.BasicServicesKit';

// 显式声明表单验证结果接口
export interface ValidateResult {
  valid: boolean;
  message: string;
}

// 注册请求参数接口
export interface RegisterRequest {
  username: string;
  password: string;
  nickname: string;
  major: string;
  grade: number;
  interestTags: string;
}



@Entry
@Component
struct RegisterPage {
  // 扩展注册表单状态（匹配后端接口参数）
  @State username: string = "";
  @State password: string = "";
  @State confirmPassword: string = "";
  @State nickname: string = "";
  @State major: string = "";
  @State grade: string = ""; // 先存字符串，提交时转数字
  @State interestTags: string = "";
  @State message: string = "";
  @State loading: boolean = false;

  private componentContext: common.Context = getContext(this);

  // 页面首次渲染初始化
  aboutToAppear() {
    this.message = "";
  }

  /**
   * 注册按钮点击事件处理
   */
  async onRegisterClick() {
    // 1. 表单验证
    const validateResult: ValidateResult = this.validateForm();
    if (!validateResult.valid) {
      this.message = validateResult.message;
      promptAction.showToast({ message: validateResult.message });
      return;
    }

    // 2. 构造注册请求参数
    const registerData: RegisterRequest = {
      username: this.username.trim(),
      password: this.password.trim(),
      nickname: this.nickname.trim(),
      major: this.major.trim(),
      grade: Number(this.grade.trim()),
      interestTags: this.interestTags.trim()
    };

    // 3. 发起注册请求
    this.loading = true;
    this.message = "";
    try {
      const res: RegisterResponse = await (await import('../common/HttpClient')).HttpClient.postJson<RegisterResponse>(
        "/api/user/register",
        registerData
      );

      console.log("注册接口返回结果：", JSON.stringify(res));
      console.log("注册接口返回code：", res.code);


      // 4. 处理注册响应
      if (res.code === 200) {
        router.pushUrl({ url: "pages/LoginPage" });
      } else {
        this.message = res.msg || "注册失败，请稍后重试";
        promptAction.showToast({ message: this.message });
      }
    } catch (err) {
      let errorMsg = "注册失败：网络异常或服务器错误";
      let errorCode = -1; // 默认异常码
      if (err instanceof BusinessError) {
        // 业务错误（接口返回code≠200）
        errorCode = err.code || -1;
        errorMsg = err.message || errorMsg;
        // 打印包含code的详细错误日志
        console.error(`注册失败 - code: ${errorCode}, msg: ${errorMsg}`, err);
      } else if (err instanceof Error) {
        // 原生Error（如网络错误、JSON解析错误）
        console.error(`注册接口调用异常 - 错误信息: ${err.message}`, err);
      } else {
        // 其他未知错误（转成字符串打印）
        console.error(`注册接口调用失败 - 未知错误: ${JSON.stringify(err)}`, err);
      }

      this.message = `${errorMsg}（错误码：${errorCode}）`;
      promptAction.showToast({ message: this.message });
    } finally {
      this.loading = false;
    }
  }

  /**
   * 表单验证逻辑（包含所有必填字段）
   */
  private validateForm(): ValidateResult {
    // 用户名验证
    if (!this.username.trim()) {
      return { valid: false, message: "用户名不能为空" };
    }
    if (this.username.length < 3 || this.username.length > 20) {
      return { valid: false, message: "用户名长度需在3-20位之间" };
    }

    // 密码验证
    if (!this.password.trim()) {
      return { valid: false, message: "密码不能为空" };
    }
    if (this.password.length < 6) {
      return { valid: false, message: "密码长度不能少于6位" };
    }
    if (this.password !== this.confirmPassword) {
      return { valid: false, message: "两次输入的密码不一致" };
    }

    // 昵称验证
    if (!this.nickname.trim()) {
      return { valid: false, message: "昵称不能为空" };
    }

    // 专业验证
    if (!this.major.trim()) {
      return { valid: false, message: "专业不能为空" };
    }

    // 年级验证
    if (!this.grade.trim()) {
      return { valid: false, message: "年级不能为空" };
    }
    const gradeNum = Number(this.grade);
    if (isNaN(gradeNum) || gradeNum < 2000 || gradeNum > new Date().getFullYear() + 1) {
      return { valid: false, message: "请输入有效的入学年级（如2023）" };
    }

    // 兴趣标签验证
    if (!this.interestTags.trim()) {
      return { valid: false, message: "兴趣标签不能为空" };
    }
    // 验证标签格式：仅包含1-5的数字，逗号分隔
    const tagArr = this.interestTags.split(',').map(tag => tag.trim());
    const isValidTags = tagArr.every(tag => /^[1-5]$/.test(tag));
    if (!isValidTags) {
      return { valid: false, message: "兴趣标签只能是1-5的数字，逗号分隔（如1,3）" };
    }

    // 所有验证通过
    return { valid: true, message: "" };
  }

  build() {
    Column({ space: 15 }) {
      // 页面标题
      Text("学伴领航")
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 });
      Text("用户注册")
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 20 });

      // 用户名输入框
      TextInput({ placeholder: "请输入用户名（3-20位）", text: this.username })
        .width("80%")
        .onChange((v: string) => {
          this.username = v;
          this.message = "";
        });

      // 密码输入框
      TextInput({ placeholder: "请输入密码（至少6位）", text: this.password })
        .width("80%")
        .type(InputType.Password)
        .onChange((v: string) => {
          this.password = v;
          this.message = "";
        });

      // 确认密码输入框
      TextInput({ placeholder: "请确认密码", text: this.confirmPassword })
        .width("80%")
        .type(InputType.Password)
        .onChange((v: string) => {
          this.confirmPassword = v;
          this.message = "";
        });

      // 昵称输入框
      TextInput({ placeholder: "请输入昵称", text: this.nickname })
        .width("80%")
        .onChange((v: string) => {
          this.nickname = v;
          this.message = "";
        });

      // 专业输入框
      TextInput({ placeholder: "请输入专业（如：计算机科学）", text: this.major })
        .width("80%")
        .onChange((v: string) => {
          this.major = v;
          this.message = "";
        });

      // 年级输入框
      TextInput({ placeholder: "请输入入学年级（如：2023）", text: this.grade })
        .width("80%")
        .type(InputType.Number)
        .onChange((v: string) => {
          this.grade = v;
          this.message = "";
        });

      // 兴趣标签输入框
      TextInput({ placeholder: "请输入兴趣标签（1-5数字，逗号分隔，如：1,3）", text: this.interestTags })
        .width("80%")
        .onChange((v: string) => {
          this.interestTags = v;
          this.message = "";
        });

      // 错误提示文本
      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor(Color.Red)
          .margin(10)
          .width("80%")
          .textAlign(TextAlign.Center);
      }

      // 注册按钮
      Button(this.loading ? "注册中..." : "注册")
        .width("60%")
        .enabled(!this.loading)
        .backgroundColor(this.loading ? Color.Grey : Color.Blue)
        .margin({ bottom: 10 })
        .onClick(() => {
          this.onRegisterClick();
        });

      // 返回登录按钮
      Button("返回登录")
        .width("60%")
        .backgroundColor(Color.White)
        .fontColor(Color.Blue)
        .border({ width: 1, color: Color.Blue })
        .onClick(() => {
          router.back();
        });
    }
    .width("100%")
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Center);
  }
}
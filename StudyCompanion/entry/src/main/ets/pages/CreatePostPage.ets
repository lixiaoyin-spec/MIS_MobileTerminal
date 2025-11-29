import router from '@ohos.router';
import { HttpClient } from '../common/HttpClient';
import { ApiResponse } from '../common/ApiResponse';

export interface CreatePostVO {
  title: string;
  content: string;
  token: string;
}

@Entry
@Component
struct CreatePostPage {
  @State title: string = "";
  @State content: string = "";
  @State loading: boolean = false;
  @State errorMsg: string = "";

  async submitPost() {
    if (!this.title || !this.content) {
      this.errorMsg = "标题和内容不能为空";
      return;
    }

    this.errorMsg = "";
    this.loading = true;

    try {
      const token = AppStorage.get("token") as string;

      const body: CreatePostVO = {
        title: this.title,
        content: this.content,
        token: token
      };

      const res: ApiResponse<null> =
        await HttpClient.postJson<ApiResponse<null>>("/api/post/create", body, token);

      if (res.code !== 200) {
        this.errorMsg = res.msg;
      } else {
        router.replaceUrl({ url: "pages/ForumPage" });
      }

    } catch (e) {
      this.errorMsg = "网络错误";
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {

      Text("发布帖子")
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      TextInput({ placeholder: "请输入标题" })
        .width("90%")
        .height(50)
        .fontSize(18)
        .border({ width: 1 })
        .margin({ bottom: 20 })
        .onChange(v => this.title = v)

      TextInput({ placeholder: "请输入帖子内容", text: this.content })
        .width("90%")
        .height(200)
        .border({ width: 1 })
        .fontSize(16)
        .onChange(v => this.content = v)
        .margin({ bottom: 20 })

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontColor(Color.Red)
          .margin({ bottom: 10 })
      }

      Button("提交帖子")
        .width("70%")
        .height(50)
        .fontSize(20)
        .backgroundColor("#007DFF")
        .fontColor(Color.White)
        .onClick(() => this.submitPost())

      if (this.loading) {
        Text("提交中...")
          .fontSize(16)
          .margin({ top: 10 })
      }

    }
    .width("100%")
    .padding(20)
  }
}

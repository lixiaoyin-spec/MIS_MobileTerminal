import router from '@ohos.router';
import request from '@ohos.request';
import promptAction from '@ohos.promptAction';
import common from '@ohos.app.ability.common';
import { GlobalContext } from '../common/GlobalContext';

/* ---------- SDK 类型：严格根据你报错推断（ArkTS-safe） ---------- */

interface UploadFile {
  name: string;       // 表单字段
  filename: string;   // 上传文件名
  uri: string;        // 文件 URI
  type: string;       // MIME
}

interface UploadFormField {
  name: string;
  value: string;
}

interface UploadConfig {
  url: string;
  method: string;
  header?: Record<string, string>;
  files: UploadFile[];
  data?: UploadFormField[];
}

interface UploadCompleteResult {
  code: number;
  data: string;
  msg?: string;
}

interface UploadTask {
  on(event: "progress", callback: (uploadedSize: number, totalSize: number) => void): void;
  on(event: "headerReceive", callback: (header: object) => void): void;
  on(event: "complete", callback: (result: UploadCompleteResult) => void): void;
  on(event: "fail", callback: (err: object) => void): void;
}

/* ---------------------------------------------------- */

@Entry
@Component
struct ResourceUploadPage {
  @State filePath: string = "";
  @State uploading: boolean = false;
  @State uploadUrl: string = "";
  @State errorMsg: string = "";

  token = AppStorage.get("token") as string;

  private getAbilityContext(): common.UIAbilityContext {
    return GlobalContext.getAbilityContext<common.UIAbilityContext>();
  }

  async uploadResource() {
    const ctx = this.getAbilityContext();

    const fileItem: UploadFile = {
      filename: "test.pdf",
      name: "file",
      uri: this.filePath,
      type: "application/pdf"
    };

    const config: request.UploadConfig = {
      url: "http://10.6.2.184:8081/api/resource/upload",
      method: "POST",
      files: [fileItem],
      data: [
        { name: "token", value: this.token }
      ],
      header: {
        "Authorization": `Bearer ${this.token}`
      }
    };

    request.uploadFile(ctx, config, (err, task) => {
      if (err) {
        console.error("启动上传任务失败:", JSON.stringify(err));
        return;
      }

      task.on("progress", (uploaded, total) => {
        console.log(`上传进度：${uploaded}/${total}`);
      });

      task.on("complete", (result) => {
        console.log("上传完成:", JSON.stringify(result));
      });

      task.on("fail", (result) => {
        console.error("上传失败:", JSON.stringify(result));
      });
    });
  }


  build() {
    Column({ space: 14 }) {

      Row() {
        Text("< 返回")
          .fontSize(18)
          .onClick(() => router.back());
        Blank().layoutWeight(1);
        Text("资源上传")
          .fontSize(20)
          .fontWeight(FontWeight.Bold);
        Blank().layoutWeight(1);
      }
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor("#F5F5F5");

      TextInput({
        placeholder: "请输入文件 URI",
        text: this.filePath
      })
        .width("100%")
        .height(60)
        .border({ width: 1 })
        .onChange((v: string) => this.filePath = v);

      Button(this.uploading ? "上传中..." : "上传文件")
        .width("70%")
        .backgroundColor("#007DFF")
        .fontColor(Color.White)
        .enabled(!this.uploading)
        .onClick(() => this.uploadResource());

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontColor(Color.Red)
          .fontSize(16);
      }

      if (this.uploadUrl) {
        Text("上传成功：")
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 12 });
        Text(this.uploadUrl)
          .fontColor(Color.Blue);
      }

    }
    .padding(20)
  }
}

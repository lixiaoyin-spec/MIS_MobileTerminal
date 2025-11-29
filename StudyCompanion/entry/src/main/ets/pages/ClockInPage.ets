import router from '@ohos.router';
import { HttpClient } from '../common/HttpClient';
import { ApiResponse } from '../common/ApiResponse';

export interface ClockItem {
  id: number;
  nickname: string;
  content: string;
  clockDate: string;
  createTime: string;
}

interface GeneratedObjectLiteralInterface_1 {
  content: string;
  token: string;
}

@Entry
@Component
struct ClockInPage {
  @State inputText: string = "";
  @State errorMsg: string = "";
  @State historyList: ClockItem[] = [];

  async aboutToAppear() {
    this.loadClockHistory();
  }

  /** 查询所有打卡记录 */
  async loadClockHistory() {
    const token = AppStorage.get("token") as string | undefined;
    if (!token) {
      this.errorMsg = "未登录";
      return;
    }

    try {
      const res: ApiResponse<ClockItem[]> =
        await HttpClient.get<ApiResponse<ClockItem[]>>(
          `/api/clock/list?token=${token}`,
          token
        );

      if (res.code === 200 && Array.isArray(res.data)) {
        this.historyList = res.data;
      } else {
        this.historyList = [];
      }
    } catch (e) {
      console.error("loadClockHistory error:", e);
      this.errorMsg = "加载打卡记录失败";
    }
  }

  /** 提交打卡 */
  async submitClockIn() {
    const token = AppStorage.get("token") as string | undefined;
    if (!token) {
      this.errorMsg = "未登录";
      return;
    }

    if (!this.inputText.trim()) {
      this.errorMsg = "打卡内容不能为空";
      return;
    }

    this.errorMsg = "";

    try {
      const body: GeneratedObjectLiteralInterface_1 = {
        content: this.inputText.trim(),
        token: token
      };

      const res: ApiResponse<null> =
        await HttpClient.postJson<ApiResponse<null>>(
          "/api/clock/add",
          body,
          token
        );

      if (res.code === 200) {
        this.inputText = "";
        this.loadClockHistory();
      } else {
        this.errorMsg = res.msg || "打卡失败";
      }
    } catch (e) {
      console.error("submitClockIn error:", e);
      this.errorMsg = "提交打卡失败";
    }
  }

  /** 打卡记录卡片 */
  @Builder
  ClockCard(item: ClockItem) {
    Column() {
      Text(item.clockDate)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)

      Text(item.content)
        .fontSize(16)
        .margin({ top: 6 })

      Text(item.createTime)
        .fontSize(12)
        .fontColor(Color.Grey)
        .margin({ top: 4 })
    }
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      /** 返回栏 */
      Row() {
        Text("< 返回")
          .fontSize(18)
          .onClick(() => router.back())

        Blank().layoutWeight(1)
      }
      .height(50)
      .padding({ left: 10, right: 10 })
      .backgroundColor("#F5F5F5")

      Text("每日打卡")
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      /** 输入框 */
      TextInput({ placeholder: "写下今天的学习内容..." })
        .width("100%")
        .height(60)
        .border({ width: 1 })
        .onChange((v: string) => this.inputText = v)

      /** 提交按钮 */
      Button("提交打卡")
        .width("60%")
        .margin({ top: 10 })
        .backgroundColor("#007DFF")
        .fontColor(Color.White)
        .onClick(() => this.submitClockIn())

      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontColor(Color.Red)
          .margin({ top: 10 })
      }

      /** 历史信息标题 */
      Text("历史打卡记录")
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 30, bottom: 10 })

      /** 打卡历史列表 */
      List() {
        ForEach(this.historyList, (item: ClockItem) => {
          ListItem() { this.ClockCard(item) }
        })
      }

    }
    .padding(20)
    .height('100%')
  }
}

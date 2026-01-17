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
    Row() {
      // Date Column
      Column() {
        Text(item.clockDate.split('-')[2] || '01') // Day
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#007DFF')
        Text(item.clockDate.substring(0, 7)) // Year-Month
          .fontSize(12)
          .fontColor('#999')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width(60)
      .margin({ right: 12 })
      .justifyContent(FlexAlign.Center)

      // Content Column
      Column() {
        Text(item.content)
          .fontSize(16)
          .fontColor('#333')
          .lineHeight(22)
          .margin({ bottom: 8 })
        
        Text(item.createTime)
          .fontSize(12)
          .fontColor('#999')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12, left: 16, right: 16 })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
  }

  build() {
    Column() {
      /** 顶部标题栏 */
      Row() {
        Text("<")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .onClick(() => {
            router.back();
          })
        
        Text("每日打卡")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 44 })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
      .zIndex(1)

      List() {
        // 打卡输入区域
        ListItem() {
          Column() {
            Text("今天学了什么？")
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
              .margin({ bottom: 16 })
              .width('100%')

            TextArea({ placeholder: "记录一下今天的学习收获吧...", text: this.inputText })
              .width("100%")
              .height(120)
              .backgroundColor('#F5F7FA')
              .borderRadius(12)
              .padding(12)
              .onChange((v: string) => this.inputText = v)

            Button("立即打卡")
              .width("100%")
              .height(44)
              .margin({ top: 20 })
              .backgroundColor("#007DFF")
              .fontColor(Color.White)
              .borderRadius(22)
              .onClick(() => this.submitClockIn())
              .shadow({ radius: 8, color: 'rgba(0,125,255,0.3)', offsetY: 4 })
            
            if (this.errorMsg) {
              Text(this.errorMsg)
                .fontColor(Color.Red)
                .fontSize(14)
                .margin({ top: 12 })
            }
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(16)
          .margin(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.05)', offsetY: 4 })
        }

        /** 历史信息标题 */
        ListItem() {
          Text("历史记录")
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
            .padding({ left: 20, top: 8, bottom: 12 })
        }

        /** 打卡历史列表 */
        ForEach(this.historyList, (item: ClockItem) => {
          ListItem() { this.ClockCard(item) }
        })

        ListItem().height(20) // 底部留白
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F7FA')
    }
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}

import router from '@ohos.router';
import aiApi from '../common/AiApi';
import { UserStore } from '../store/UserStore';
import common from '@ohos.app.ability.common';

interface Message {
  role: 'user' | 'ai';
  content: string;
}

@Entry
@Component
struct AiChatPage {
  @State messages: Message[] = [{ role: 'ai', content: '你好！我是你的AI助手，有什么可以帮助你的吗？' }];
  @State userInput: string = '';
  @State isLoading: boolean = false;
  private scroller: Scroller = new Scroller();
  private userStore: UserStore = new UserStore();
  private context: common.Context = getContext(this);

  async aboutToAppear() {
    await this.userStore.init(this.context);
  }

  scrollToBottom() {
    // 稍微延迟以确保列表渲染完成
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  async sendMessage() {
    const messageText: string = this.userInput.trim();
    if (messageText === '' || this.isLoading) {
      return;
    }

    // 1. 添加用户消息
    this.messages.push({ role: 'user', content: messageText });
    
    // 2. 清空输入框 (ArkTS @State 绑定会自动更新 UI)
    this.userInput = ''; 
    
    this.isLoading = true;
    this.scrollToBottom();

    try {
      const token: string = this.userStore.token;
      if (!token) {
        throw new Error('用户未登录');
      }
      const reply: string = await aiApi.postChatMessage(messageText, token);
      this.messages.push({ role: 'ai', content: reply });
    } catch (err) {
      const msg: string = (err instanceof Error ? err.message : String(err));
      this.messages.push({ role: 'ai', content: `抱歉，服务暂时无法连接。错误: ${msg}` });
    } finally {
      this.isLoading = false;
      this.scrollToBottom();
    }
  }

  @Builder
  MessageBubble(msg: Message) {
    Row() {
      if (msg.role === 'user') {
        // 用户消息靠右
        Blank()
        Text(msg.content)
          .fontSize(16)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .padding(12)
          .borderRadius({ topLeft: 12, topRight: 0, bottomLeft: 12, bottomRight: 12 })
          .margin({ left: 40, right: 10 })
          .copyOption(CopyOptions.LocalDevice)
      } else {
        // AI 消息靠左
        Text(msg.content)
          .fontSize(16)
          .backgroundColor(Color.White)
          .fontColor('#333')
          .padding(12)
          .borderRadius({ topLeft: 0, topRight: 12, bottomLeft: 12, bottomRight: 12 })
          .margin({ left: 10, right: 40 })
          .copyOption(CopyOptions.LocalDevice)
          .shadow({ radius: 2, color: '#11000000', offsetY: 1 })
        Blank()
      }
    }
    .width('100%')
    .margin({ bottom: 16 })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .width(50)
          .height('100%')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            router.back();
          })
        Text('AI 助手')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 50 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#007DFF')

      // 聊天窗口
      List({ scroller: this.scroller }) {
        ForEach(this.messages, (item: Message, index: number) => {
          ListItem() {
            this.MessageBubble(item)
          }
        }, (item: Message, index: number) => `${index}_${item.role}`)
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor('#F5F7FA')
      .padding({ top: 16, bottom: 16 })

      // 输入区域
      Row() {
        TextInput({ placeholder: '输入你的问题...', text: this.userInput })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.userInput = value;
          })
          .onSubmit(() => {
            this.sendMessage();
          })

        Button(this.isLoading ? '...' : '发送')
          .height(36)
          .width(70)
          .margin({ left: 10 })
          .backgroundColor(this.isLoading ? '#ccc' : '#007DFF')
          .enabled(!this.isLoading)
          .onClick(() => {
            this.sendMessage();
          })
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor('#f0f0f0')
    }
    .height('100%')
  }
}

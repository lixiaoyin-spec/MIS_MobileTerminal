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
    this.scroller.scrollEdge(Edge.Bottom);
  }

  async sendMessage() {
    const messageText: string = this.userInput.trim();
    if (messageText === '' || this.isLoading) {
      return;
    }

    this.messages.push({ role: 'user', content: messageText });
    this.userInput = '';
    this.isLoading = true;
    this.scrollToBottom();

    try {
      const token: string = this.userStore.token; // 修复：使用 .token 属性
      if (!token) {
        throw new Error('用户未登录');
      }
      const reply: string = await aiApi.postChatMessage(messageText, token);
      this.messages.push({ role: 'ai', content: reply });
    } catch (err) {
      const msg: string = (err instanceof Error ? err.message : String(err));
      this.messages.push({ role: 'ai', content: `抱歉，服务暂时无法连接，请稍后再试。错误: ${msg}` });
      console.error(`Failed to get AI reply: ${msg}`);
    } finally {
      this.isLoading = false;
      this.scrollToBottom();
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('<')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width(56)
          .height(56)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White) // 修复：将 fontColor 应用于 Text
          .onClick(() => {
            router.back();
          })
        Text('AI 助手')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 56 })
          .fontColor(Color.White) // 修复：将 fontColor 应用于 Text
      }
      .width('100%')
      .height(56)
      .backgroundColor('#007DFF')

      // 聊天窗口
      Scroll(this.scroller) {
        Column() {
          ForEach(this.messages, (item: Message) => {
            MessageBubble({ message: item })
          })
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
      }
      .layoutWeight(1)
      .backgroundColor('#f5f7fa')

      // 输入区域
      Row() {
        TextInput({ placeholder: '输入你的问题...', text: this.userInput })
          .onChange((value: string) => { // 修复：为回调参数添加类型
            this.userInput = value;
          })
          .layoutWeight(1)
          .height(40)
          .padding({ left: 15, right: 15 })
          .backgroundColor(Color.White)
          .onSubmit(() => {
            this.sendMessage();
          })

        Button('发送')
          .onClick(() => {
            this.sendMessage();
          })
          .height(40)
          .margin({ left: 10 })
          .enabled(!this.isLoading)
      }
      .width('100%')
      .padding(10)
      .border({ width: { top: 1 }, color: '#e0e0e0' })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct MessageBubble {
  message: Message = { role: 'ai', content: '' };

  build() {
    Row() {
      Text(this.message.content)
        .padding(12)
        .borderRadius(12)
        .backgroundColor(this.message.role === 'user' ? '#007DFF' : Color.White)
        .fontColor(this.message.role === 'user' ? Color.White : Color.Black)
        .lineHeight(22)
        .fontSize(16)
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .justifyContent(this.message.role === 'user' ? FlexAlign.End : FlexAlign.Start)
  }
}

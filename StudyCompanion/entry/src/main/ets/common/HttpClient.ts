import http from '@ohos.net.http';
import fs from '@ohos.file.fs';

export class HttpClient {
  private static BASE_URL = "http://10.6.2.184:8081";

  /** POST（自动加入 Bearer token） */
  static async postJson<T>(path: string, data: object, token?: string): Promise<T> {
    const httpRequest = http.createHttp();
    const headers: Record<string, string> = { "Content-Type": "application/json" };
    if (token) headers["Authorization"] = `Bearer ${token}`;

    try {
      const fullUrl = this.getFullUrl(path);
      console.info("POST URL:", fullUrl);
      console.info("POST body:", JSON.stringify(data));

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(data),
        connectTimeout: 60000,
        readTimeout: 60000
      });

      return this.parseResponse<T>(response);
    } finally {
      httpRequest.destroy();
    }
  }

  /** GET（自动加入 token） */
  static async get<T>(path: string, token?: string): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = this.getFullUrl(path);
      const headers: Record<string, string> = {};
      if (token) headers["Authorization"] = `Bearer ${token}`;

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: headers,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      return this.parseResponse<T>(response);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * POST multipart/form-data（支持文件字段与普通字段）
   * formData: { key: string | { uri: string } }
   * token: 可选，自动放到 Authorization: Bearer ...
   */
  static async postForm<T>(
    path: string,
    formData: { [key: string]: string | { uri: string } },
    token?: string
  ): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const fullUrl = this.getFullUrl(path);
      console.info("POST FORM URL:", fullUrl);

      const multiFormDataList: http.MultiFormData[] = [];

      // 遍历传入的 formData 对象，区分文件与普通字段
      for (const key in formData) {
        if (!Object.prototype.hasOwnProperty.call(formData, key)) continue;
        const val = formData[key];

        if (typeof val === "object" && val !== null && (val as { uri?: string }).uri) {
          // 文件字段：读取文件为 ArrayBuffer/Uint8Array
          const uri = (val as { uri: string }).uri;
          console.info(`Reading file for form field "${key}" from uri:`, uri);
          const bytes = await this.readFileBytes(uri);
          multiFormDataList.push({
            name: key,
            contentType: "application/octet-stream",
            data: bytes.buffer
          });
        } else {
          // 普通字段 -> 转为 UTF-8 bytes
          const s = String(val ?? "");
          const bytes = this.encodeUtf8(s);
          multiFormDataList.push({
            name: key,
            contentType: "text/plain",
            data: bytes.buffer
          });
        }
      }

      const headers: Record<string, string> = {};
      if (token) headers["Authorization"] = `Bearer ${token}`;

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        multiFormDataList: multiFormDataList,
        connectTimeout: 60000,
        readTimeout: 60000
      });

      return this.parseResponse<T>(response);
    } finally {
      httpRequest.destroy();
    }
  }

  /** 统一解析 http.HttpResponse -> JSON */
  private static parseResponse<T>(response: http.HttpResponse): T {
    console.info("HTTP Code:", response.responseCode);
    const raw = response.result ? response.result.toString() : "";
    console.info("Raw Result:", raw);

    if (response.responseCode !== 200) {
      // 抛出更容易定位的错误
      throw new Error(`HTTP ${response.responseCode} - ${raw}`);
    }

    try {
      return JSON.parse(raw) as T;
    } catch (e) {
      throw new Error(`JSON parse error: ${(e as Error).message} - raw: ${raw}`);
    }
  }

  /** 辅助：把字符串编码为 UTF-8 Uint8Array（替代 TextEncoder） */
  private static encodeUtf8(str: string): Uint8Array {
    // 简单的 UTF-8 编码函数（兼容 ArkTS 环境）
    const encoder: number[] = [];
    for (let i = 0; i < str.length; i++) {
      let codePoint = str.charCodeAt(i);

      if (codePoint < 0x80) {
        encoder.push(codePoint);
      } else if (codePoint < 0x800) {
        encoder.push(0xc0 | (codePoint >> 6));
        encoder.push(0x80 | (codePoint & 0x3f));
      } else if (codePoint < 0xd800 || codePoint >= 0xe000) {
        encoder.push(0xe0 | (codePoint >> 12));
        encoder.push(0x80 | ((codePoint >> 6) & 0x3f));
        encoder.push(0x80 | (codePoint & 0x3f));
      } else {
        // surrogate pair
        i++;
        if (i >= str.length) break;
        const second = str.charCodeAt(i);
        const surrogate = 0x10000 + (((codePoint & 0x3ff) << 10) | (second & 0x3ff));
        encoder.push(0xf0 | (surrogate >> 18));
        encoder.push(0x80 | ((surrogate >> 12) & 0x3f));
        encoder.push(0x80 | ((surrogate >> 6) & 0x3f));
        encoder.push(0x80 | (surrogate & 0x3f));
      }
    }
    return new Uint8Array(encoder);
  }

  /**
   * 尝试读取 file URI 为 Uint8Array
   *
   * 说明：
   * - 在不同 OHOS SDK 版本中，@ohos.file.fs 的 API 可能略有差异。
   * - 我们先尝试使用常见的 readFile 接口（如果存在），否则尝试 open/stat/read/close 的组合。
   */
  private static async readFileBytes(uri: string): Promise<Uint8Array> {
    try {
      // 优先尝试存在的简单接口 readFile（返回 object 包含 bytes/array）
      // 注意：不同 SDK 的返回结构不同，这里做保护性判断
      if (typeof (fs as any).readFile === 'function') {
        // @ts-ignore - 部分 SDK 上 readFile 返回 { bytes: Uint8Array } 或 Buffer-like
        const result = await (fs as any).readFile(uri);
        if (result && result.bytes && result.bytes instanceof Uint8Array) {
          return result.bytes as Uint8Array;
        }
        if (result && result instanceof Uint8Array) {
          return result as Uint8Array;
        }
        // 如果返回的是 string，则转为 Uint8Array（假设为 base64 或文本 —— 这里仅做兜底）
        if (typeof result === 'string') {
          return this.encodeUtf8(result);
        }
      }

      // 否则尝试 open/stat/read/close 式（较底层）
      // 不同 SDK 名称可能不同，请根据 IDE 的提示调整为 open/read/stat 的正确方法名
      const openRes = await (fs as any).open(uri);
      const stat = await (fs as any).stat(uri);
      const size = stat ? stat.size ?? stat.length ?? 0 : 0;

      if (!openRes || typeof openRes.fd === 'undefined') {
        throw new Error('readFileBytes: open() 没有返回 fd，请检查 SDK API');
      }

      const fd = openRes.fd;
      const buffer = new ArrayBuffer(size);
      const uint8 = new Uint8Array(buffer);

      // read 可能在不同 SDK 中签名不同，尝试常见的调用方式
      if (typeof (fs as any).read === 'function') {
        await (fs as any).read(fd, uint8, 0, size, 0);
      } else if (typeof (fs as any).readSync === 'function') {
        // 少数 SDK 可能提供 sync 版本
        (fs as any).readSync(fd, uint8, 0, size, 0);
      } else {
        throw new Error('readFileBytes: fs.read 方法不可用，请检查 SDK 版本');
      }

      // close
      if (typeof (fs as any).close === 'function') {
        await (fs as any).close(fd);
      } else if (typeof (fs as any).closeSync === 'function') {
        (fs as any).closeSync(fd);
      }

      return uint8;
    } catch (err) {
      console.error('readFileBytes fail:', err);
      throw err;
    }
  }

  /** 统一 URL 处理 */
  private static getFullUrl(path: string): string {
    const base = this.BASE_URL.replace(/\/$/, "");
    const p = path.startsWith("/") ? path : `/${path}`;
    return `${base}${p}`;
  }
}

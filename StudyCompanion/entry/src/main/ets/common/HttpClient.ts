import http from '@ohos.net.http';

export default class HttpClient {

  // 后端服务器基础地址
  private static BASE_URL: string = "http://你的后端IP:端口";

  /**
   * GET 请求
   */
  static async get(path: string): Promise<any> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        this.BASE_URL + path,
        {
          method: http.RequestMethod.GET,
          connectTimeout: 60000,
          readTimeout: 60000,
        }
      );

      return this.parseResponse(response);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * POST 提交 JSON
   */
  static async postJson(path: string, data: Object): Promise<any> {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        this.BASE_URL + path,
        {
          method: http.RequestMethod.POST,
          header: {
            "Content-Type": "application/json"
          },
          extraData: JSON.stringify(data),
          connectTimeout: 60000,
          readTimeout: 60000
        }
      );

      return this.parseResponse(response);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 上传文件（使用 multiFormDataList）
   */
  static async uploadFile(path: string, fieldName: string, fileBytes: Uint8Array) {
    const httpRequest = http.createHttp();

    try {
      const response = await httpRequest.request(
        this.BASE_URL + path,
        {
          method: http.RequestMethod.POST,
          header: {
            "Content-Type": "multipart/form-data"
          },
          multiFormDataList: [
            {
              name: fieldName,
              contentType: "application/octet-stream",
              data: fileBytes.buffer  // 必须是 ArrayBuffer
            }
          ],
          connectTimeout: 60000,
          readTimeout: 60000,
        }
      );

      console.log("Response code:", response.responseCode);
      console.log("Result:", response.result);

      return response.result;

    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 响应解析（兼容 OH API）
   */
  private static parseResponse(response: any): any {
    if (!response || !response.result) {
      return null;
    }

    const raw = response.result;

    try {
      if (typeof raw === "string") {
        return JSON.parse(raw);
      }
    } catch (_) { }

    return raw;
  }
}

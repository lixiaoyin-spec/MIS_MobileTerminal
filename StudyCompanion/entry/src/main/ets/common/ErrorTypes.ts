// common/ErrorTypes.ts（纯 TS 文件，所有 TS/ArkTS 文件均可导入）
export class BusinessError extends Error {
  code?: number; // 可选错误码
  constructor(message: string, code?: number) {
    super(message);
    this.code = code;
    this.name = 'BusinessError'; // 标记错误类型
    // 修复原型链（可选，增强类型判断准确性）
    Object.setPrototypeOf(this, BusinessError.prototype);
  }
}
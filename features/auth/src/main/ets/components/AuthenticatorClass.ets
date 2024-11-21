import cryptoFramework from '@ohos.security.cryptoFramework';

export type OtpTypes = 'TOTP';
export type OtpAlgorithms = 'SHA1' | 'SHA256' | 'SHA512';

export interface AuthenticatorClassOptions {
  id: number;
  issuer: string;
  secret: string;
  account?: string;
  algorithm?: OtpAlgorithms;
  protocol?: OtpTypes;
  digits?: number;
  updateInterval?: number
}

export class AuthenticatorClass {
  private _id: number;                        // 验证器 ID
  private _issuer: string;                    // 发行者
  private _account: string | null = null;     // 账号，如邮箱
  private _secret: string;                    // 密钥，通常为 16 位
  private _protocol: OtpTypes = 'TOTP';       // 密钥更新协议，默认/常用为 TOTP，暂不支持 HOTP）
  private _algorithm: OtpAlgorithms = 'SHA1'; // 密钥生成算法，默认/常用为 SHA1
  private _digits: number = 6;                // OTP 位数，默认/常用为 6 位
  private _updateInterval: number = 30;       // 更新周期，默认 30s

  constructor(options: AuthenticatorClassOptions) {
    this._id = options.id;
    this._issuer = options.issuer;
    this._secret = options.secret;
    if (options.account) this._account = options.account;
    if (options.algorithm) this._algorithm = options.algorithm;
    if (options.protocol) this._protocol = options.protocol;
    if (options.digits) this._digits = options.digits;
    if (options.updateInterval) this._updateInterval = options.updateInterval;
  }

  get id(): number { return this._id; }
  get issuer(): string { return this._issuer; }
  get account(): string | null { return this._account; }
  get digits(): number { return this._digits; }
  get updateInterval(): number { return this._updateInterval; }

  private getTimeCounter(): number {
    const currentTimestamp = Math.floor(Date.now() / 1000);  // 以秒为单位的时间戳
    const counter = Math.floor(currentTimestamp / this._updateInterval);

    return counter;
  }

  private base32Decode(secret: string): Uint8Array {
    const base32Str = secret.replace(/=/g, "").toUpperCase();

    // 确定字节数组长度
    const byteLength = Math.floor(base32Str.length * 5 / 8);
    const result = new Uint8Array(byteLength);

    let buffer = 0;
    let bitsLeft = 0;
    let index = 0;

    // Base32 字符集
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

    for (let char of base32Str) {
      const val = alphabet.indexOf(char);

      // 忽略无效字符
      if (val === -1) continue;

      // 将值左移到缓冲区并跟踪剩余位数
      buffer = (buffer << 5) | val;
      bitsLeft += 5;

      // 从缓冲区提取字节
      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        result[index++] = (buffer >> bitsLeft) & 0xff;
      }
    }

    return result;
  }

  private packCounter(counter: number): Uint8Array {
    // 创建 8 字节的 ArrayBuffer
    const buffer = new ArrayBuffer(8);
    const view = new DataView(buffer);

    // 设置 view 为 64 位无符号整数（大端字节序）
    view.setBigUint64(0, BigInt(counter), false);

    // 打包成字节的计数器
    const packedCounter = new Uint8Array(buffer);
    return packedCounter;
  }

  private async getHash(secret: string, counter: number): Promise<Uint8Array> {
    // 获取解码的密钥 & 打包的计数器
    let decodedSecret = this.base32Decode(secret);
    let packedCounter = this.packCounter(counter);

    const key = await cryptoFramework.createSymKeyGenerator('HMAC').convertKey({ data: decodedSecret });

    const mac = cryptoFramework.createMac(this._algorithm);
    await mac.init(key);
    await mac.update({ data: packedCounter });

    const hash = await mac.doFinal();
    return hash.data
  }

  private calculateOTP(hash: Uint8Array) {
    // 根据最后一个字节的低 4 位计算偏移量
    const offset = hash[hash.length - 1] & 0xf;
    // 从哈希中提取 4 个字节，计算 OTP
    const code = ((hash[offset] & 0x7f) << 24 |
      (hash[offset + 1] & 0xff) << 16 |
      (hash[offset + 2] & 0xff) << 8  |
      (hash[offset + 3] & 0xff));
    return code;
  }

  async getCode(): Promise<string> {
    const hash = await this.getHash(this._secret, this.getTimeCounter());
    const otpCode = this.calculateOTP(hash);

    return (otpCode % Math.pow(10, this._digits)).toString().padStart(this._digits, '0');

  }
}
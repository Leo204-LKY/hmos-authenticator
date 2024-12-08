import url from '@ohos.url';
import { AuthenticatorClassOptions, OtpAlgorithms } from '../models/AuthenticatorClass';
import { Preferences } from '../models/Preferences';
import { ValuesBucket } from '@kit.ArkData';
import { RelationalStore } from '../models/RelationalStore';

// otpauth://totp/Issuer:account?secret=OTPSECRET2345678&issuer=Issuer

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

export async function addAuthenticatorFromUrl(otpUrl: string) {
  const regex = /otpauth:\/\/([a-zA-Z0-9]+)\/([^\?]+)\?(.+)/;
  const match = otpUrl.match(regex);

  if (!match) {
    console.warn('Invalid otpauth URL format');
    throw new Error('Invalid otpauth URL format');
  }

  const protocol = match[1];
  const label = match[2];
  const queryString = match[3];

  const params = new url.URLParams('?' + queryString);
  const labelArray = label.split(':');

  let issuer = labelArray[0].replaceAll('%20', ' ');
  let account = labelArray[1].replaceAll('%20', ' ');

  const secret = params.get('secret');
  const algorithm = params.get('algorithm') as OtpAlgorithms;
  const digits = parseInt(params.get('digits') || '6', 10);
  const updateInterval = parseInt(params.get('period') || '30', 10);

  if (!secret) {
    throw new Error('Secret is required in the URL.')
  }

  let authenticatorSequence = await preferences.get('authenticatorSequence', []) as number[];
  let values: ValuesBucket = {
    issuer: issuer,
    account: account,
    secret: secret,
    protocol: protocol,
    algorithm: algorithm || 'SHA1',
    digits: digits,
    update_interval: updateInterval
  }

  let rowId = await rdbStore.insert('authenticator', values)

  if (rowId != -1) {
    authenticatorSequence.push(rowId);
    preferences.set('authenticatorSequence', authenticatorSequence);
  }
}
import { AuthenticatorClass, AuthenticatorClassOptions, OtpAlgorithms, OtpTypes } from '../models/AuthenticatorClass';
import { RelationalStore } from '../models/RelationalStore';
import { Preferences } from '../models/Preferences';
import { relationalStore } from '@kit.ArkData';
import { PreferenceConstants } from '../models/PreferenceConstants';

interface AuthenticatorData {
  authenticators: AuthenticatorClass[];
  authenticatorSequence: number[];
}

const rdbStore = RelationalStore.getInstance();
const preferences = Preferences.getInstance();

export async function getAuthenticators(): Promise<AuthenticatorClass[]> {
  let authenticatorData: AuthenticatorData = await getUnorderedAuthenticators()
  return reorderAuthenticators(authenticatorData.authenticatorSequence, authenticatorData.authenticators);
}

async function getUnorderedAuthenticators(): Promise<AuthenticatorData> {
  let predicates: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('authenticator');
  let queryResult = await rdbStore.getAll(predicates);
  let authenticators: AuthenticatorClass[] = [];
  let authenticatorSequence = await preferences.get(PreferenceConstants.AUTHENTICATOR_SEQUENCE, []) as number[];

  for (let i = 0; i < queryResult.length; i++) {
      let options: AuthenticatorClassOptions = {
        id: queryResult[i].id as number,
        issuer: queryResult[i].issuer as string,
        account: queryResult[i].account as string,
        secret: queryResult[i].secret as string,
        otpType: queryResult[i].protocol as OtpTypes,
        algorithm: queryResult[i].algorithm as OtpAlgorithms,
        digits: queryResult[i].digits as number,
        updateInterval: queryResult[i].update_interval as number
      }

      authenticators.push(new AuthenticatorClass(options));
  }

  return {authenticators: authenticators, authenticatorSequence: authenticatorSequence};
}

function reorderAuthenticators(sequence: number[], authenticators: AuthenticatorClass[]): AuthenticatorClass[] {
  let reorderedAuthenticators: AuthenticatorClass[] = [];

  for (let i = 0; i < sequence.length; i++) {
    for (let j = 0; j < authenticators.length; j++) {
      if (sequence[i] == authenticators[j].id) {
        reorderedAuthenticators.push(authenticators[j]);
        authenticators.splice(j, 1);
        break;
      }
    }
  }

  return reorderedAuthenticators;
}
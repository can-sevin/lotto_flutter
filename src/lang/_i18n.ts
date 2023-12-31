import I18n from 'i18n-js'
import * as RNLocalize from 'react-native-localize'
import tr from './tr'
import en from './en'
import es from './es'
import fr from './fr'
import it from './it'
import ru from './ru'

const locales = RNLocalize.getLocales()
I18n.locale = locales[0].languageTag
I18n.fallbacks = true
I18n.locales.no = 'en'
I18n.translations = {
  en,
  tr,
  es,
  fr,
  it,
  ru
}
export default I18n

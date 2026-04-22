/// All user-facing text in clean French, following the Vaulted Gallery theme.
class AppStrings {
  static const appName = 'QuranPlay';
  static const brandName = 'Vaulted Gallery';

  // ── Biometric Gate ──
  static const secureAccessRequired = 'Accès sécurisé requis';
  static const scanFingerprint = 'Scannez votre empreinte pour accéder à votre galerie privée chiffrée.';
  static const systemReady = 'SYSTÈME PRÊT';
  static const systemSettings = 'Paramètres système';
  static const authenticate = 'Authentifier';
  static const authenticating = 'Vérification…';
  static const fingerprintDetected = 'Empreinte détectée…';
  static const secureConnectionValidated = 'Connexion sécurisée validée.';
  static const success = 'Succès';

  // ── Login ──
  static const welcomeBack = 'Bon retour';
  static const enterCredentials = 'Entrez vos identifiants pour accéder au coffre.';
  static const emailAddress = 'ADRESSE E-MAIL';
  static const emailPlaceholder = 'nom@exemple.com';
  static const password = 'MOT DE PASSE';
  static const forgotPassword = 'Mot de passe oublié ?';
  static const login = 'Se connecter';
  static const orAccessVia = 'OU ACCÉDEZ VIA';
  static const continueWithGoogle = 'Google';
  static const biometric = 'Biométrie';
  static const noAccount = 'Pas de compte ?';
  static const createAccount = 'Créer un compte';
  static const loading = 'Chargement…';

  // ── Register ──
  static const createIdentity = 'Créer une identité';
  static const completeProfile = 'Complétez votre profil d\'inscription biométrique.';
  static const firstName = 'PRÉNOM';
  static const lastName = 'NOM';
  static const masterKey = 'CLÉ MAÎTRESSE';
  static const dateOfBirth = 'DATE DE NAISSANCE';
  static const dateOfBirthHint = 'jj/mm/aaaa';
  static const securityNote = 'Vos données sont chiffrées de bout en bout. Vous devez avoir au moins 13 ans.';
  static const alreadyHaveAccount = 'Déjà un compte ?';
  static const signIn = 'Se connecter';

  // ── Forgot Password ──
  static const resetAccess = 'Réinitialiser l\'accès';
  static const resetDescription = 'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation sécurisé.';
  static const sendResetLink = 'Envoyer le lien';
  static const backToLogin = 'Retour à la connexion';
  static const resetLinkSent = 'Lien de réinitialisation envoyé ! Vérifiez votre boîte mail.';
  static const encryptionActive = 'CHIFFREMENT AES-256 ACTIF';

  // ── Dashboard ──
  static const securityStatusActive = 'STATUT DE SÉCURITÉ : ACTIF';
  static const welcomeUser = 'Bienvenue,';
  static const dashboardSubtitle = 'Votre analyse d\'écoute est prête. Consultez vos métriques privées.';
  static const totalListeningTime = 'TEMPS D\'ÉCOUTE TOTAL';
  static const monthlyGoal = 'Objectif mensuel';
  static const progress = 'PROGRESSION';
  static const dailyAvg = 'MOY. JOUR';
  static const streak = 'SÉRIE';
  static const remaining = 'RESTANT';
  static const listeningHistogram = 'Histogramme d\'écoute';
  static const dailyStreamVolume = 'Volume quotidien';
  static const topTracks = 'Titres les plus écoutés';
  static const viewFullAnalysis = 'Voir l\'analyse complète';
  static const completed = 'complété';
  static const target = 'Cible :';
  static const noTracksYet = 'Aucun titre écouté pour le moment.';

  // ── Player ──
  static const nowStreamingSecurely = 'LECTURE SÉCURISÉE';
  static const categories = 'Catégories';
  static const viewAll = 'TOUT VOIR';
  static const reciters = 'Récitateurs';
  static const topSurahs = 'SOURATES';
  static const noReciters = 'Aucun récitateur disponible.';
  static const playbackError = 'Impossible de lire ce titre. Vérifiez votre connexion.';
  static const networkError = 'Pas de connexion internet. Vérifiez votre réseau.';
  static const apiError = 'Impossible de charger les données. Réessayez.';
  static const searchRecitersHint = 'Rechercher un récitateur…';
  static const searchSurahsHint = 'Rechercher une sourate…';
  static const allReciters = 'Tous les récitateurs';
  static const noResults = 'Aucun résultat trouvé.';
  static const radioLive = 'Radio Live';
  static const radioLiveDesc = 'Radio Coran du Caire — En direct 24/7';
  static const radioUnavailable = 'Radio indisponible pour le moment.';

  // ── Favorites ──
  static const favorites = 'Favoris';
  static const noFavorites = 'Aucun favori pour le moment.';
  static const addedToFavorites = 'Ajouté aux favoris.';
  static const favoriteError = 'Impossible d\'ajouter aux favoris. Réessayez.';
  static const biometricAuthToRemove = 'Authentification biométrique requise';
  static const confirmRemoveFavorite = 'Confirmez votre identité pour modifier vos enregistrements sécurisés.';
  static const authorizeWithTouchId = 'Autoriser avec Touch ID';
  static const cancelAction = 'Annuler';
  static const authRequired = 'Authentification requise pour continuer.';
  static const firestoreAccessDenied = 'Accès refusé. Reconnectez-vous ou déployez les règles Firestore.';
  static const loadingFavoritesError = 'Impossible de charger vos favoris. Réessayez.';

  // ── Bottom Nav ──
  static const navVault = 'Coffre';
  static const navStream = 'Écouter';
  static const navPulse = 'Insights';
  static const navFavoris = 'Favoris';
  static const navProfile = 'Profil';

  // ── Profile ──
  static const profileTitle = 'Profil Vault';
  static const profileVerifiedOperator = 'OPÉRATEUR VÉRIFIÉ';
  static const profileAccountInfo = 'INFORMATIONS DU COMPTE';
  static const profileEmail = 'Adresse e-mail';
  static const profileJoinedDate = 'Date d\'inscription';
  static const profileSettings = 'PARAMÈTRES';
  static const profileTheme = 'Thème';
  static const profileThemeValue = 'Émeraude Nuit';
  static const profileLanguage = 'Langue';
  static const profileLanguageValue = 'Français (FR)';
  static const profileNotifications = 'Notifications';
  static const profileNotificationsValue = 'Toutes actives';
  static const profileLogout = 'DÉCONNEXION';

  // ── Explore ──
  static const exploreTitle = 'EXPLORER';
  static const quranIndex = 'Index du Coran';
  static const surahs = 'sourates';
  static const surahLabel = 'Sourate';
  static const verses = 'versets';
  static const searchSurahHint = 'Rechercher une sourate…';
  static const filterAll = 'Toutes';
  static const filterMeccan = 'Mecquoise';
  static const filterMedinan = 'Médinoise';
  static const meccan = 'MECQUOISE';
  static const medinan = 'MÉDINOISE';

  // ── Azkar ──
  static const azkarTitle = 'Azkar';
  static const categoriesLabel = 'catégories';
  static const tapToCount = 'Appuyez pour compter';

  // ── Duas ──
  static const duasTitle = 'Duas & Invocations';

  // ── Mushaf ──
  static const mushafTitle = 'Mushaf Al-Quran';
  static const pageLabel = 'Page';
  static const mushafUnavailable = 'Les images du Mushaf ne sont pas disponibles.';
  static const imageLoadError = 'Impossible de charger l\'image.';

  // ── Laylat Al-Qadr ──
  static const laylatAlQadrSubtitle = 'La Nuit du Destin — Guide complet';

  // ── Prayer Times ──
  static const prayerTimesTitle = 'HORAIRES DE PRIÈRE';

  // ── General ──
  static const logout = 'Déconnexion';
  static const retry = 'Réessayer';
  static const genericError = 'Un problème est survenu. Veuillez réessayer.';

  // ── Offline / Downloads ──
  static const offlineBanner = 'Mode hors ligne — Lecture depuis le cache';
  static const downloadsTitle = 'Téléchargements';
  static const navDownloads = 'Hors ligne';
  static const noDownloads = 'Aucun téléchargement pour le moment.';
  static const noDownloadsHint = 'Téléchargez des sourates depuis le lecteur\npour les écouter sans connexion.';
  static const deleteAll = 'Tout supprimer';
  static const deleteAllConfirmTitle = 'Supprimer tous les téléchargements ?';
  static const deleteAllConfirmBody = 'Cette action supprimera tous les fichiers audio téléchargés de votre appareil.';
  static const downloadStarted = 'Téléchargement en cours…';
  static const downloadComplete = 'Téléchargé avec succès !';
  static const downloadError = 'Échec du téléchargement. Réessayez.';
  static const alreadyDownloaded = 'Déjà téléchargé.';
  static const offlineReady = 'HORS LIGNE';
  static const playingOffline = 'Lecture hors ligne';

  // ── Additional ──
  static const greeting = 'Bienvenue,';
  static const welcomeSubtitle = 'Explorez le Coran et enrichissez votre écoute.';
  static const currentMonth = 'ce mois-ci';
  static const noDataYet = 'Aucune donnée pour le moment.';
  static const hoursUnit = 'heures';
  static const prayerTimes = 'Horaires de prière';
  static const prayerTimesUnavailable = 'Horaires non disponibles.';
  static const quickAccess = 'Accès rapide';
  static const tracks = 'pistes';
  static const downloads = 'Téléchargements';
  static const offlineAvailable = 'Disponible hors ligne';
  static const downloadTracksHint = 'Téléchargez des titres depuis le lecteur.';
  static const editProfile = 'Modifier le profil';
  static const securitySettings = 'Paramètres de sécurité';
  static const about = 'À propos';
  static const guest = 'Invité';
  static const totalListening = 'Écoute totale';
  static const daysActive = 'Jours actifs';
  static const repeat = 'Répéter';
  static const previous = 'Précédent';
  static const next = 'Suivant';
}

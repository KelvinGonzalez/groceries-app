enum Language {
  english(key: "english"),
  spanish(key: "spanish");

  final String key;

  const Language({required this.key});

  static Language fromKey(String key) =>
      Language.values.where((e) => e.key == key).first;
}

enum TranslatedText {
  households(en: "Households", es: "Familias"),
  createHousehold(en: "Create Household", es: "Crear Familia"),
  enterName(en: "Enter name...", es: "Ingrese un nombre..."),
  joinHousehold(en: "Join Household", es: "Unirse a la Familia"),
  enterAccessCode(en: "Enter access code...", es: "Ingrese código de acceso"),
  householdMustHaveName(
      en: "Household must have a name", es: "Familia debe tener un nombre"),
  cannotJoinHousehold(
      en: "Cannot join household", es: "No puede unirse a la familia"),
  householdDoesNotExist(
      en: "Household does not exist", es: "La familia no existe"),
  options(en: "Options", es: "Opciones"),
  light(en: "Light", es: "Claro"),
  dark(en: "Dark", es: "Oscuro"),
  shoppingLists(en: "Shopping Lists", es: "Listas de Compras"),
  items(en: "Items", es: "Artículos"),
  recipes(en: "Recipes", es: "Recetas"),
  createList(en: "Create List", es: "Crear Lista"),
  areYouSure(en: "Are you sure?", es: "¿Estás seguro?"),
  enterItemName(en: "Enter item name...", es: "Ingrese nombre de artículo..."),
  enterCategoryName(
      en: "Enter category name...", es: "Ingrese nombre de categoría..."),
  item(en: "Item", es: "Artículo"),
  category(en: "Category", es: "Categoría"),
  createRecipe(en: "Create Recipe", es: "Crear Receta"),
  yes(en: "Yes", es: "Sí"),
  no(en: "No", es: "No"),
  accessCodeCopied(en: "Access code copied", es: "Código de acceso copiado"),
  accessCode(en: "Access Code", es: "Código de Acceso"),
  menu(en: "Menu", es: "Menú"),
  changeName(en: "Change Name", es: "Cambiar Nombre"),
  enterNewName(en: "Enter new name...", es: "Ingrese nombre nuevo..."),
  cancel(en: "Cancel", es: "Cancelar"),
  submit(en: "Submit", es: "Someter"),
  changeImage(en: "Change Image", es: "Cambiar Imagen"),
  changeLocation(en: "Change Location", es: "Cambiar Ubicación"),
  copying(en: "Copying", es: "Copiando"),
  enterCopyName(en: "Enter copy name...", es: "Ingrese nombre de copia..."),
  copy(en: "Copy", es: "Copiar"),
  delete(en: "Delete", es: "Borrar"),
  categoryMatch(
      en: "Category Recommendation", es: "Recomendación de Categoría"),
  accept(en: "Accept", es: "Aceptar"),
  decline(en: "Decline", es: "Rechazar"),
  categoryRecommendations(en: "Recommendations", es: "Recomendaciones");

  const TranslatedText({required this.en, this.es});

  final String en;
  final String? es;

  String get(Language language) {
    switch (language) {
      case Language.english:
        return en;
      case Language.spanish:
        return es ?? en;
    }
  }
}

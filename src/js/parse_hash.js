function parseHash(c, forms, skinLayers, hairLayers){
    newParseHash();
    var formsLength = forms.length;
    var formsCounter = formsLength;
    while (formsCounter--) {
        var f = formsLength - formsCounter - 1;
        for(var x in forms[f]) {
            var section =  x.toLowerCase();
            if (section === 'pupils') {
              modCharacter(section, hashData);
            }
            if (section ==='brows'||section === 'eyes'||section === 'mouth'||section === 'lashes'||section === 'sockets'){
                var hashData = hash.get('emotion');
                if (hashData === undefined) {
                    hashData = 'neutral';
                }
            } else {
                var hashData = hash.get(section);
            }
            var id = section + '_' + hashData;
            if (hashData != undefined){
                modCharacter(section, hashData);
                // ga('send', 'event', 'hash', 'select', id);
            } else if (section === 'brows'||section === 'eyes'||section === 'mouth'||section === 'lashes'||section === 'sockets') {
                modCharacter(section, 'neutral');
            };
            if (id in skinLayers || section ==='body') {
                section = 'skin';
            }
            else if (id in hairLayers || section ==='hair'){ section = 'hair'};
            var hashColor = hash.get(section+'Color');
            if (hashColor != undefined && hashColor != '') {
                modCharacter(section+'Color', hashColor);
                // ga('send', 'event', 'hash', 'color', section+'_'+hashColor );
            };
        };
    };
};

function newParseHash() {
  var hashDict = hash.get();
  var keys = Object.keys(hashDict);
  var key;
  for (key in hashDict) {
    if (hashDict[key] === '') {hash.remove(key);}
  }
  if (hashDict['irisColor'] != '') {
      modCharacter('irisColor', hashDict['irisColor']);
  }
}

function hashCharacter() {
      var u = currentUser.cc.personnages[currentUser.cc.personnageActuel]
      var r
      var t = []
      for (r in u) {
        t.push(encodeURIComponent(r) + '=' + encodeURIComponent(u[r]))
      }
      if (t.length) {
        personnageActuelToHash(currentUser);
      }
}

function personnageActuelToHash(currentUser) {
    var personnageActuel = currentUser.cc.personnageActuel;
    var personnageActuelData;
    var itemsList;
    var itemsCounter;
    var currentCount;
    var myKey;
    var myValue;
    var hashArgs = {};

    if (personnageActuel && personnageActuel !== '') {
        personnageActuelData = currentUser.cc.personnages[personnageActuel];
        itemsList = Object.keys(personnageActuelData);
        itemsListLength = itemsList.length;
        itemsListCounter = itemsListLength;
        while (itemsListCounter--) {
            currentCount = itemsListLength - itemsListCounter - 1;
            myKey = itemsList[currentCount];
            myValue = personnageActuelData[itemsList[currentCount]];
            hashArgs[myKey] = myValue;
            hash.add(hashArgs);
        }
        clearCharacter();
        interpretHash();
    } else {
        return;
    }
}

function interpretHash() {
    var hashSex = hash.get("sex");
    if (hashSex === "m") {
        selectMale();
    } else if (hashSex === "f") {
        selectFemale();
    }
}

const fs = require('fs');
const path = require('path');

const paises = [
  'MEX','RSA','KOR','CZE','CAN','BIH','QAT','SUI',
  'BRA','MAR','HAI','SCO','USA','PAR','AUS','TUR',
  'GER','CUW','CIV','ECU','NED','JPN','SWE','TUN',
  'BEL','EGY','IRN','NZL','ESP','CPV','KSA','URU',
  'FRA','SEN','IRQ','NOR','ARG','ALG','AUT','JOR',
  'POR','COD','UZB','COL','ENG','CRO','GHA','PAN',
];

const outputDir = path.join(__dirname, '..', 'qr_codes');
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

let total = 0;
for (const iso3 of paises) {
  for (let numero = 1; numero <= 20; numero++) {
    const data = { equipo_iso3: iso3, lamina_numero: numero };
    fs.writeFileSync(
      path.join(outputDir, `${iso3}${numero}.json`),
      JSON.stringify(data)
    );
    total++;
  }
}

console.log(`Generados ${total} archivos JSON en qr_codes/`);

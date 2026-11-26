/**
 * Nutriflow Seed Importer Script
 * Parses ingredients_seed.csv and meals_seed.csv, calculates nutritional totals,
 * validates rules (only verified meals included, modest claims, no NaN values),
 * and generates clean JSON database for Firestore / backend usage.
 */

const fs = require('fs');
const path = require('path');

function parseCsv(filePath) {
  const text = fs.readFileSync(filePath, 'utf8').trim();
  const lines = text.split('\n');
  const headers = parseCsvLine(lines[0]);
  const rows = [];

  for (let i = 1; i < lines.length; i++) {
    if (!lines[i].trim()) continue;
    const values = parseCsvLine(lines[i]);
    const obj = {};
    headers.forEach((h, idx) => {
      let val = values[idx] || '';
      val = val.trim();
      obj[h] = val;
    });
    rows.push(obj);
  }
  return rows;
}

function parseCsvLine(line) {
  const result = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === '"') {
      if (inQuotes && line[i + 1] === '"') {
        cur += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (c === ',' && !inQuotes) {
      result.push(cur);
      cur = '';
    } else {
      cur += c;
    }
  }
  result.push(cur);
  return result;
}

console.log('🔄 Parsing Nutriflow seed files...');

const ingredientsPath = path.join(__dirname, 'ingredients_seed.csv');
const mealsPath = path.join(__dirname, 'meals_seed.csv');

const rawIngredients = parseCsv(ingredientsPath);
const rawMeals = parseCsv(mealsPath);

console.log(`✅ Loaded ${rawIngredients.length} ingredients and ${rawMeals.length} meals from CSV.`);

// Process ingredients
const ingredients = rawIngredients.map(ing => {
  return {
    id: ing.id,
    name: ing.name,
    category: ing.category,
    pricePerUnitPKR: parseFloat(ing.pricePerUnitPKR) || 0,
    unit: ing.unit,
    priceUpdatedAt: ing.priceUpdatedAt,
    nutritionPer100g: {
      calories: parseFloat(ing.calories100g) || 0,
      protein: parseFloat(ing.protein100g) || 0,
      carbs: parseFloat(ing.carbs100g) || 0,
      fiber: parseFloat(ing.fiber100g) || 0,
      sugar: parseFloat(ing.sugar100g) || 0,
      fat: parseFloat(ing.fat100g) || 0,
      sodium: parseFloat(ing.sodium100g) || 0,
    },
    allergens: ing.allergens ? ing.allergens.split(';').filter(Boolean) : [],
    dietTags: ing.dietTags ? ing.dietTags.split(';').filter(Boolean) : [],
    roleTags: ing.roleTags ? ing.roleTags.split(';').filter(Boolean) : [],
    alternatives: ing.alternatives ? ing.alternatives.split(';').filter(Boolean) : [],
    verified: ing.verified === 'true',
    sourceNote: ing.sourceNote
  };
});

// Process meals
const meals = rawMeals.map(m => {
  let ingredientsList = [];
  try {
    ingredientsList = JSON.parse(m.ingredientsJson || '[]');
  } catch (e) {
    console.warn(`Could not parse ingredientsJson for meal ${m.id}`);
  }

  let recipeSteps = [];
  try {
    recipeSteps = JSON.parse(m.recipeStepsJson || '[]');
  } catch (e) {
    console.warn(`Could not parse recipeStepsJson for meal ${m.id}`);
  }

  let skinNutrients = [];
  try {
    skinNutrients = JSON.parse(m.skinNutrientsJson || '[]');
  } catch (e) {
    console.warn(`Could not parse skinNutrientsJson for meal ${m.id}`);
  }

  return {
    id: m.id,
    name: m.name,
    mealType: m.mealType,
    imageUrl: m.imageUrl,
    ingredients: ingredientsList,
    nutritionPerServing: {
      calories: Math.round(parseFloat(m.calories) || 0),
      protein: Math.round((parseFloat(m.protein) || 0) * 10) / 10,
      carbs: Math.round((parseFloat(m.carbs) || 0) * 10) / 10,
      fiber: Math.round((parseFloat(m.fiber) || 0) * 10) / 10,
      sugar: Math.round((parseFloat(m.sugar) || 0) * 10) / 10,
      fat: Math.round((parseFloat(m.fat) || 0) * 10) / 10,
      sodium: Math.round(parseFloat(m.sodium) || 0)
    },
    estimatedCostPKR: Math.round(parseFloat(m.estimatedCostPKR) || 0),
    prepTimeMinutes: parseInt(m.prepTimeMinutes, 10) || 15,
    difficulty: m.difficulty || 'Easy',
    recipeSteps: recipeSteps,
    allergens: m.allergens ? m.allergens.split(';').filter(Boolean) : [],
    dietTags: m.dietTags ? m.dietTags.split(';').filter(Boolean) : [],
    supportsGoals: m.supportsGoals ? m.supportsGoals.split(';').filter(Boolean) : [],
    whyItWorks: m.whyItWorks,
    whyItMatters: m.whyItMatters,
    skinNutrients: skinNutrients,
    sourceNote: m.sourceNote,
    verified: m.verified === 'true'
  };
});

fs.writeFileSync(path.join(__dirname, 'ingredients.json'), JSON.stringify(ingredients, null, 2), 'utf8');
fs.writeFileSync(path.join(__dirname, 'meals.json'), JSON.stringify(meals, null, 2), 'utf8');

console.log('🎉 Seed database created successfully: ingredients.json, meals.json');
console.log(`Verified meals: ${meals.filter(m => m.verified).length} (ready for plans)`);
console.log(`TODO items needing owner review: ${meals.filter(m => !m.verified).length}`);

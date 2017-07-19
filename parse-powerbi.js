const fs = require('fs')
const util = require('util')

// Input 
//DIR = ''
LAYOUTPATH = 'Layout_TranBank-2_DigitalBehavior'
content_str = fs.readFileSync(LAYOUTPATH, 'ucs2')

//if (!fs.existsSync(DIR)){
//    fs.mkdirSync(DIR);
//}
// ucs2 is approximately utf-16
// console.log(content_str.substring(0,5000))

contents = JSON.parse(content_str)

// All
//console.log(contents)

resourcePackages = contents.resourcePackages.map(o => {
    return o.resourcePackage.items.map(item => {
        if (item.content) {
            return item.content.substring(0,1000)
        } else {
            return ''
        }
    })
})
//console.log(resourcePackages)

// UTIL
/* pad(10, 4);      // 0010
 * pad(9, 4);       // 0009
 * pad(123, 4);     // 0123
 * pad(10, 4, '-'); // --10
 */
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

function _extractProperty(expression) {
    // can be GroupRef, Column or Measure
    /*
    { GroupRef:
       { Expression: { SourceRef: { Source: 'm1' } },
         Property: 'tran_sub_type (groups)',
         GroupedColumns:
          [ { Column:
               { Expression: { SourceRef: { Source: 'm1' } },
                 Property: 'tran_sub_type' } } ] } },
    */
    return expression.GroupRef ? 
        expression.GroupRef.GroupedColumns[0].Column.Property :
        (expression.Column ? 
            expression.Column.Property : 
                expression.Measure.Property)
}

function _extractName(columnOrMeasure) {
    return columnOrMeasure.Column ? columnOrMeasure.Column.Name : columnOrMeasure.Measure.Name 
}

//console.log(filter_objs)
function recursiveCondition(cond, tblPrefix) {
    for (var k in cond) {
        if (k === 'Not') {
            return `Not (${recursiveCondition(cond.Not.Expression, tblPrefix)})`
        } else if (k === 'In') {
            combinedCond = cond.In.Values.map(value => {
                // Example Values: [ [ { Literal: { Value: '\'MCS\'' } } ] ] } } },
                return value[0].Literal.Value.replace(/\'/g, '')
            }).join("', '")
            if (cond.In.Expressions.length > 1) {
                throw TypeError('Expressions > 1')
            }
            return `${tblPrefix}.${_extractProperty(cond.In.Expressions[0])} In ('${combinedCond}')`
        } else if (k === 'Comparison') {
            lookupComparisonKind = {
                0: 'In',
                1: '>'
            }
            return `${tblPrefix}.${_extractProperty(cond.Comparison.Left)} ${lookupComparisonKind[cond.Comparison.ComparisonKind]} ${cond.Comparison.Right.Literal.Value.replace('D','')}`
        } else if (k === 'Or') {
            return `${recursiveCondition(cond.Or.Left, tblPrefix)} Or ${recursiveCondition(cond.Or.Right, tblPrefix)}`
        } else {
            throw new TypeError(k)
        }
    }
}

function recursiveLog(deepObject) {
    console.log(util.inspect(deepObject, { showHidden: false, depth: null }))
}

//console.log(contents.sections)
var parse_sections = contents.sections.map(section => {
    //console.log('=== section ===', util.inspect(section, {showHidden: false, depth: null}))
    //console.log('[INFO] working on sheet: ', section.displayName)
    section.visualContainers = section.visualContainers.map(visualContainer => {
        // Parse json first
        ['dataTransforms', 'query', 'config', 'filters'].forEach( attr => {
            if (visualContainer[attr]) {            
                visualContainer[attr] = JSON.parse(visualContainer[attr])
            }
        })
        return visualContainer
    })
    return section
})
//console.log(parse_sections)

var transformed_sections = parse_sections.map(section => {
    //console.log('=== section ===', util.inspect(section, {showHidden: false, depth: null}))
    //console.log('[INFO] working on sheet: ', section.displayName)
    return section.visualContainers.filter(visualContainer => {
        return visualContainer.config || visualContainer.filters
    }).map(visualContainer => {

        var name_str = ''
        var condition_str = ''
        //console.log('[INFO] working on visual at x,y : ', visualContainer.x, visualContainer.y)
        // 1 config
        // 2 filters
        try {
            if (visualContainer.config) {            
                config = visualContainer.config
                if(config.singleVisual) {
                    //if (config.singleVisual.objects.general[0].properties.filter){
                    //    console.log('[INFO] working on visual at x,y : ', visualContainer.x, visualContainer.y)
                    //    recursiveLog(config.singleVisual.objects.general[0].properties.filter)
                    //}
                    //console.log('=== CONFIG ===', util.inspect(config, {showHidden: false, depth: null}))
                    if (config.singleVisual.prototypeQuery) {            
                        //console.log('      ', 'Name: ', config.singleVisual.prototypeQuery.Select[0].Name)
                        name_str = config.singleVisual.prototypeQuery.Select.map(s => s.Name).join(', ')
                        // can be Column.Name, Measure.Name, GroupRef.Name
                    }
                }
                visualContainer.config = config
            }

            if (visualContainer.filters) {            
                filters = visualContainer.filters
                //console.log('=== FILTER ===', util.inspect(filters, {showHidden: false, depth: null}))
                conditions =  filters.map(filter => {
                    if (filter.filter) {
                        var table =  filter.filter.From[0].Entity
                        if (filter.filter.From.length > 1) {
                            console.log('=== From > 1 ===', util.inspect(filters, false, null))
                        }
                        var cond =  filter.filter.Where[0].Condition
                        if (filter.filter.Where.length > 1) {
                            console.log('=== Where > 1 ===', util.inspect(filters, false, null))
                        }
                        var field = _extractProperty(filter.expression)
                        //return table + '.' + field + ' ' + recursiveCondition(cond, table)
                        return recursiveCondition(cond, table)
                    }
                })
                //console.log('      ', 'Condition: ', conditions.join(', '))
                visualContainer.filters = filters
                condition_str = conditions.join(', ')
            }


            //var newObject = Object.keys(myObject).reduce(function(previous, current) {
            //    previous[current] = myObject[current] * myObject[current];
            //    return previous;
            //}, {});

        } catch(err) {
            console.log('=== visualContainer ===', util.inspect(visualContainer, false, null))
            console.log()
            console.error(err)
            //console.error('Type Error at ', visualContainer)
        }

        return {
            name: section.displayName,
            number: section.visualNumber,
            x: visualContainer.x,
            y: visualContainer.y,
            name_str: name_str,
            condition_str: condition_str
        }
    }).filter(visualContainer => {
        return visualContainer.name_str || visualContainer.condition_str
    }).map( visualContainer => {
        // Power BI default size 1280*720
        // grid by 40: 1280/40 , 720/40
        //xSortIndex = pad(parseInt(visualContainer.x/ 18), 3)
        xSortIndex = pad(parseInt(visualContainer.x/ 25), 3)
        ySortIndex = pad(parseInt(visualContainer.y/ 32), 3)
        // left->right line by line
        // visualContainer.sortIndex = ySortIndex + xSortIndex
        // top->bottom line by line
        visualContainer.sortIndex = xSortIndex + ySortIndex
        return  visualContainer
    }).sort( (a,b) => {
        return a.sortIndex - b.sortIndex
    })
})


//fs.writeFileSync(LAYOUTPATH + '.json', util.inspect(transformed_sections, { showHidden: false, depth: null }))
fs.writeFileSync(LAYOUTPATH + '.json', JSON.stringify(transformed_sections, null, 4))
fs.writeFileSync(LAYOUTPATH + '.raw.json', JSON.stringify(parse_sections, null, 4))
fs.writeFileSync(LAYOUTPATH + '.txt', transformed_sections.reduce((result_str, section) => {
    result_str += section.reduce( (str, visualContainer) => {
        csv_str = [visualContainer.name, visualContainer.x, visualContainer.y, visualContainer.name_str, visualContainer.condition_str].join(';')
        str += csv_str + '\n'
        return str
    }, '')
    return result_str
}, ''))

/*
[ 'id',
  'theme',
  'filters',
  'resourcePackages',
  'sections',
  'config',
  'layoutOptimization',
  'pods' ]
  */

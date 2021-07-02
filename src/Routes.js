import React, { useEffect } from 'react'
import { Switch, Route } from 'react-router-dom'
import Navigation from './components/Navigation'
import Reporte from './components/InConsole'
import TablaSimbolos from './components/TablaSimbolos'
import TablaErrores from './components/TablaErrores'
import Gramatical  from './components/Gramatical'

const Routes = () => {
    useEffect(()=>{
        document.title="OLC2 - G30"
    })
    return (
        <Switch>
            <Route exact path = "/" component={Navigation}/>
            <Route exact path = "/testingPages" component={Navigation}/>
            <Route exact path = "/reporte" component={Reporte}/>
            <Route exact path = "/reporteTabla" component={TablaSimbolos}/>
            <Route exact path = "/reporteErrores" component={TablaErrores}/>
            <Route exact path = "/reporteGramatical" component={Gramatical}/>
        </Switch>
    );
}


export default Routes;

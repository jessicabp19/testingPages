import React from 'react'
import ReactDOM from 'react-dom'

export default class SimboloXQ extends React.Component {
  constructor(props)
  {
    super(props)
    this.data=new Array()
    if(this.props.data!=undefined)
    {
      this.data = this.props.data
    }
  }
  render() {
    return (
      <table className="table table-dark"> 
        <thead> 
          <tr> 
            <th>Identificador</th> 
            <th>Linea</th>
            <th>Columna</th>
            <th>Tipo</th> 
            <th>Valor</th> 
          </tr> 
        </thead>
        <tbody>
          { this.data.map(function(item){
            return (
              <tr key={item.identificador} >
                <td>{item.identificador}</td>
                <td>{item.linea}</td>
                <td>{item.columna}</td>
                <td>{item.tipo}</td>
                <td>{item.valor}</td>
                
                {/* <td>{item.stackPosition}</td> */}
              </tr>
            )
          }) }
        </tbody> 
      </table>
    )
  }
}

ReactDOM.render(
  <SimboloXQ />,
  document.getElementById('root')
)


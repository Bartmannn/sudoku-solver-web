import { useState } from 'react'

function App() {
  const [board, setBoard] = useState(
    Array(9).fill(null).map(() => Array(9).fill(0))
  )

  const handleCellChange = (rowIndex, colIndex, event) => {
    const value = event.target.value;

    if (value === '' || /^[1-9]$/.test(value)) {
      const newBoard = board.map(row => [...row]);
      newBoard[rowIndex][colIndex] = value === '' ? 0 : parseInt(value, 10);
      setBoard(newBoard);
    }
  }

  const handleSolve = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/solve', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({board: board}),
      });

      if (!response.ok) {
        throw new Error('Serwer zgłosił błąd');
      }

      const data = await response.json();

      if (data.status === "success" && data.board) {
        setBoard(data.board);
      } else {
        alert("Prolog mówi: " + data.message);
      }
    } catch (error) {
      console.error("Wystąpił błąd w sieci:", error);
      alert("Nie udało się połączyć z API!");
    }
  };

  return (
    // Tailwind classes: min-h-screen (takes full viewport height),
    // flex, items-center, justify-center (centers content perfectly)
    <div className='min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4'>

      <h1 className='text-4xl font-bold mb-8 text-gray-800'>
        Sudoku Solver
      </h1>

      {/* The Sudoku Board Container */}
      <div className='bg-white p-2 rounded-lg shadow-xl border-2 border-gray-800'>

        <div className='grid grid-cols-9 gap-0 border-2 border-gray-800'>

          {board.map((row, rowIndex) => (
            row.map((cellValue, colIndex) => {

              // Logic to draw thicker borders for 3x3 subgrids
              const isRightBorder = (colIndex + 1) % 3 === 0 && colIndex !== 8;
              const isBottomBorder = (rowIndex + 1) % 3 === 0 && rowIndex !== 8;

              return (
                <input
                  key={`${rowIndex}-${colIndex}`}
                  type='text'
                  maxLength={1}
                  value={cellValue === 0 ? '' : cellValue}
                  // onChange handler
                  onChange={(e) => handleCellChange(rowIndex, colIndex, e)}
                  className={`
                    w-10 h-10 sm:w-12 sm:h-12 text-center text-xl font-semibold
                    focus:outline-none focus:bg-blue-100 transition-colors
                    border border-gray-300
                    ${isRightBorder ? 'border-r-2 border-r-gray-800' : ''}
                    ${isBottomBorder ? 'border-b-2 border-b-gray-800' : ''}
                  `}
                />
              )
            })
          ))}
        </div>
      </div>

      <button
        onClick={handleSolve}
        className='mt-8 px-6 py-3 bg-blue-600 text-white font-bold
                  rounded-lg shadow-md hover:bg-blue-700 transition-colors'
      >
        Solve
      </button>

    </div>
  )
}

export default App

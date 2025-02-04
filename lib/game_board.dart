import 'dart:math';

import 'package:chess_game_flutter/components/piece.dart';
import 'package:chess_game_flutter/components/square.dart';
import 'package:chess_game_flutter/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/dead_piece.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'lib/images/pawn.png'
      );
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/images/pawn.png'
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png'
    );
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'lib/images/rook.png'
    );

    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png'
    );

    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'lib/images/rook.png'
    );

    // Place knight
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png'
    );
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/images/knight.png'
    );

    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png'
    );

    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/images/knight.png'
    );

    // Place bishop
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/images/bishop.png'
    );

    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png'
    );

    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/images/bishop.png'
    );

    //Place Queen
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/images/queen.png'
    );

    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/images/queen.png'
    );

    //Place King
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/images/king.png'
    );

    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/images/king.png'
    );

    board = newBoard;

  }

  void pieceSelected(int row, int col) {
    setState(() {
      if(selectedPiece == null && board[row][col] != null) {
        if(board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }

      }

      else if(board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      else if(selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
        moviePiece(row, col);
      }

      validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMovies = [];

    if(piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMovies.add([row + direction, col]);
        }

        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMovies.add([row + 2 * direction, col]);
          }
        }

        //pawns can kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMovies.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMovies.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.rook:
        var directions = [
          [-1,0], //up
          [1,0],  //down
          [0,-1], //left
          [0,1]   //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)) {
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMovies.add([newRow, newCol]); //kill
              }
              break; //blocked
            }
            candidateMovies.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if(!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              candidateMovies.add([newRow, newCol]); //capture
            }
            continue;
          }
          candidateMovies.add([newRow, newCol]);
        }

        break;
      case ChessPieceType.bishop:
        //diagonal direction
      var directions = [
        [-1,-1], //up left
        [-1,1], //up right
        [1,-1], //down left
        [1,1] // down right
      ];

      for( var direction in directions){
        var i = 1;
        while(true) {
          var newRow = row + i * direction[0];
          var newCol = col + i * direction[1];
          if(!isInBoard(newRow, newCol)){
            break;
          }
          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMovies.add([newRow, newCol]);
            }
            break;
          }
          candidateMovies.add([newRow, newCol]);
          i++;
        }
      }
        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];

        for(var direction in directions){
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMovies.add([newRow, newCol]);
              }
              break;
            }
            candidateMovies.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMovies.add([newRow, newCol]);
            }
            continue;
          }
          candidateMovies.add([newRow, newCol]);
        }
        break;
      default:
    }

    return candidateMovies;

  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if(checkSimulation) {
      for(var move in candidateMoves){
        int endRow = move[0];
        int endCol = move[1];
        if(simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void moviePiece(int newRow, int newCol){
    if(board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite){
        whitePiecesTaken.add(capturedPiece);
      }else{
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if(selectedPiece!.type == ChessPieceType.king) {
      if(selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      }else{
        blackKingPosition = [newRow, newCol];
      }
    }

    //move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if(isKingInCheck(!isWhiteTurn)){
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if(isCheckMate(!isWhiteTurn)) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: const Text("Check mate!"),
            actions: [
              TextButton(
                  onPressed: resetGame,
                  child: const Text("Play Again")
              )
            ],
          )
      );
    }

    //change turn
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    for(int i = 0; i < 8; i++) {
      for(int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, endCol){
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    List<int>? originalKingPosition;
    if(piece.type == ChessPieceType.king) {
      originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

      if(piece.isWhite){
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if(piece.type == ChessPieceType.king){
      if(piece.isWhite){
        whiteKingPosition = originalKingPosition!;
      }else{
        blackKingPosition = originalKingPosition!;
      }
    }

    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if(!isKingInCheck(isWhiteKing)){
      return false;
    }

    for(int i = 0; i < 8; i++){
      for(int j = 0; j < 8; j++){
        if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing){
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if(pieceValidMoves.isNotEmpty){
          return false;
        }
      }
    }

    return true;
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body:
      Column(
        children: [
          //White pieces taken
          Expanded(child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              )
          )
          ),

          //Game status
          Text(
            checkStatus ? "CHECK!" : ""
          ),

          //Chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) {

                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isSelected = selectedRow == row && selectedCol == col;

                  bool isValidMove = false;
                  for (var position in validMoves){
                    if(position[0] == row && position[1] == col){
                      isValidMove = true;
                    }
                  }

                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                }
            ),
          ),

          //Black pieces taken
          Expanded(child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              )
          )
          ),

        ],
      ),
    );
  }
}


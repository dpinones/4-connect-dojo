#[system]
mod initiate_system {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;
    use starknet::ContractAddress;
    use four_connect_dojo::components::{PieceColor, Position, PlayersId, Game, GameTurn};

    fn execute(
        ctx: Context,
        game_id: felt252,
        white_address: ContractAddress,
        black_address: ContractAddress
    ) {
        //initialize_game
        set !(
            ctx.world,
            game_id.into(),
            (
                Game {
                    status: true, winner: Option::None(()), 
                    }, GameTurn {
                    turn: PieceColor::White(()), 
                    }, PlayersId {
                    white: white_address, black: black_address, 
                }
            )
        )

        return ();
    }
}
